require 'spec_helper'

describe OrganizationsController do

  context "GET 'new'" do
    it "renders the registration page" do
      get :new
      response.should be_ok
      response.should render_template('new')
      assigns(:organization).should_not be_nil
      assigns(:organization).users.should_not be_empty
    end
  end

  context "POST 'create'" do
    context "when organization created successfully" do

      let(:user) { FactoryGirl.attributes_for(:user) }

      before(:each) do
        @organization = FactoryGirl.attributes_for(:organization)
        @organization[:users] = FactoryGirl.attributes_for(:user)
      end

      it "creates a new organization" do
        expect { post :create, :organization => @organization }.to change { Organization.count }.by(1)
      end

      it "redirects to root path with a flash message" do
        post :create, :organization => @organization
        response.should redirect_to(root_path)
        flash[:notice].should_not be_nil
      end

      it "makes the user created as the cso_admin for the organization" do
        post :create, :organization => @organization
        cso_admin = Organization.find_by_name(@organization[:name]).users.first
        cso_admin.role.should == "cso_admin"
      end

      it "assigns a default_locale to the organization" do
        post :create, :organization => @organization, :locale => :fr
        organization = Organization.find_by_name(@organization[:name])
        organization.default_locale.should == 'fr'
      end
    end

    context "when organization not created" do
      it "renders the new page" do
        post :create, :organization => { :users => [] }
        response.should render_template('new')
        flash[:error].should_not be_nil
      end
    end
  end

  context "GET 'index'" do
    it "allows users to see their organization only" do
      not_admin = FactoryGirl.create(:user, :organization => FactoryGirl.create(:organization))
      sign_in_as(not_admin)
      get :index
      response.should be_ok
      assigns(:organizations).should == [not_admin.organization]
    end

    it "all organizations can be managed by the super_admin" do
      super_admin = FactoryGirl.create(:super_admin_user, :role => "super_admin")
      sign_in_as(super_admin)
      get :index
      response.should be_ok
      assigns(:organizations).should == Organization.all
    end
  end

  context "PUT 'activate'" do
    context "when super_admin is logged in" do
      before(:each) do
        super_admin = FactoryGirl.create(:super_admin_user)
        sign_in_as(super_admin)
        ActionMailer::Base.deliveries.clear
      end

      it "activates the organization" do
        organization = FactoryGirl.create(:organization)
        user = FactoryGirl.create(:cso_admin_user, :organization => organization)
        put :activate, :organization_id => organization.id
        organization.reload.should be_active
      end

      it "creates a delayed job for the activation mail" do
        organization = FactoryGirl.create(:organization)
        user = FactoryGirl.create(:cso_admin_user, :organization => organization)
        expect do
          put :activate, :organization_id => organization.id
        end.to change { Delayed::Job.where(:queue => "organization_activation_mail").count }.by(1)
      end

      it "sends an activation mail to the cso admin of the organization" do
        org = FactoryGirl.create(:organization)
        user = FactoryGirl.create(:cso_admin_user, :organization => org)
        put :activate, :organization_id => org.id
        Delayed::Worker.new.work_off
        ActionMailer::Base.deliveries.should_not be_empty
        email = ActionMailer::Base.deliveries.first
        email.to.should include(user.email)
      end

      it "redirects to the organizations index page with a flash notice" do
        org = FactoryGirl.create(:organization)
        user = FactoryGirl.create(:cso_admin_user, :organization_id => org.id)
        put :activate, :organization_id => org.id

        response.should redirect_to organizations_path
        flash[:notice].should_not be_nil
      end
    end
  end

  context "PUT 'deactivate'" do
    context "when super_admin is logged in" do
      before(:each) do
        super_admin = FactoryGirl.create(:super_admin_user)
        sign_in_as(super_admin)
        ActionMailer::Base.deliveries.clear
      end

      it "sends an deactivation mail to the cso admin of the organization" do
        org = FactoryGirl.create(:organization)
        user = FactoryGirl.create(:cso_admin_user, :organization => org)
        put :deactivate, :organization_id => org.id
        ActionMailer::Base.deliveries.should_not be_empty
        email = ActionMailer::Base.deliveries.first
        email.to.should include(user.email)
        org.reload.should_not be_active
      end

      it "deactivates the organization with a flash notice" do
        org = FactoryGirl.create(:organization)
        user = FactoryGirl.create(:cso_admin_user, :organization_id => org.id)
        put :deactivate, :organization_id => org.id

        org.reload.should_not be_active
        response.should redirect_to organizations_path
        flash[:notice].should_not be_nil
      end
    end
  end

  context "GET 'show'" do
    before(:each) do
      admin = FactoryGirl.create(:super_admin_user)
      sign_in_as(admin)
    end
    it "assigns the organization" do
      organization = FactoryGirl.create(:organization)
      get :show, :id => organization.id
      response.should be_ok
      assigns(:organization).should == organization
    end

    it "renders the show page" do
      organization = FactoryGirl.create(:organization)
      get :show, :id => organization.id
      response.should render_template(:show)
    end
  end

  context "DELETE 'destroy'" do
    before(:each) do
      admin = FactoryGirl.create(:super_admin_user, :password => "foo", :password_confirmation => "foo")
      sign_in_as(admin)
    end

    context "when authentication passes" do
      let(:worker) { Delayed::Worker.new }

      it "creates a delayed job" do
        organization = FactoryGirl.create(:organization)
        expect { delete :destroy, :id => organization.id, :password => "foo" }.to change { Delayed::Job.count }.by(1)
      end

      it "soft-deletes the organization in 48 hours" do
        organization = FactoryGirl.create(:organization)
        delete :destroy, :id => organization.id, :password => "foo"
        Timecop.freeze(48.hours.from_now) { worker.work_off }
        organization.reload.should be_soft_deleted
      end

      it "soft-deletes the organization's users" do
        organization = FactoryGirl.create(:organization)
        user = FactoryGirl.create(:user, :organization => organization)
        delete :destroy, :id => organization.id, :password => "foo"
        user.reload.should be_soft_deleted
      end

      it "logs the user out" do
        organization = FactoryGirl.create(:organization)
        delete :destroy, :id => organization.id, :password => "foo"
        controller.current_user.should be_nil
      end

      it "redirects to the root page" do
        organization = FactoryGirl.create(:organization)
        delete :destroy, :id => organization.id, :password => "foo"
        response.should redirect_to root_path
        flash[:notice].should be_present
      end
    end

    context "when authentication fails" do
      it "redirects to confirmation page if no password is provided" do
        organization = FactoryGirl.create(:organization)
        delete :destroy, :id => organization.id
        response.should redirect_to_path(controller.sudo_mode.new_confirmation_url)
      end

      it "redirects to confirmation page if password is invalid" do
        organization = FactoryGirl.create(:organization)
        delete :destroy, :id => organization.id, :password => "wrong!"
        response.should redirect_to_path(controller.sudo_mode.new_confirmation_url)
      end
    end
  end
end
