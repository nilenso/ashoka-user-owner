require 'spec_helper'

describe OrganizationsController do

  context "GET 'new'" do
    it "renders the registration page" do
      get :new
      response.should be_ok
      response.should render_template('new')
    end

    it "assigns an organization" do
      get :new
      assigns(:organization).should be_a Organization
    end

    it "assigns a user" do
      get :new
      assigns(:user).should be_a User
    end
  end

  context "POST 'create'" do
    context "when the organization is created successfully" do

      let(:organization_attributes) { FactoryGirl.attributes_for(:organization) }
      let(:user_attributes) { FactoryGirl.attributes_for(:user) }
      let(:organization_with_users_attributes) { organization_attributes.merge(:users => user_attributes) }

      it "creates a new organization" do
        expect { post :create, :organization => organization_with_users_attributes }.to change { Organization.count }.by(1)
      end

      it "redirects to root path with a flash message" do
        post :create, :organization => organization_with_users_attributes
        flash[:notice].should_not be_nil
      end

      it "makes the user created as the cso_admin for the organization" do
        post :create, :organization => organization_with_users_attributes
        cso_admin = Organization.find_by_name(organization_with_users_attributes[:name]).users.first
        cso_admin.role.should == "cso_admin"
      end

      it "assigns a default_locale to the organization" do
        post :create, :organization => organization_with_users_attributes, :locale => :fr
        organization = Organization.find_by_name(organization_with_users_attributes[:name])
        organization.default_locale.should == 'fr'
      end

      it "should upload a logo along" do
        logo = fixture_file_upload('/logos/logo.png')
        post :create, :organization => organization_with_users_attributes.merge(:logo => logo)
        organization = Organization.find_by_name(organization_with_users_attributes[:name])
        organization.logo.should be_present
      end
    end

    context "when the organization is not created" do
      it "renders the new page" do
        post :create, :organization => { :users => [] }
        response.should render_template('new')
        flash[:error].should_not be_nil
      end

      it "assigns an organization" do
        post :create, :organization => { :users => [] }
        assigns(:organization).should be_a Organization
      end

      it "assigns a user" do
        post :create, :organization => { :users => [] }
        assigns(:user).should be_a User
      end
    end
  end

  context "GET 'edit'" do
    it "assigns the organization" do
      organization = FactoryGirl.create(:organization)
      sign_in_as(FactoryGirl.create(:cso_admin_user, :organization_id => organization.id))
      get :edit, :id => organization.id
      response.should be_ok
      assigns(:organization).should == organization
    end

    it "returns a bad response when the organization ID passed is invalid" do
      expect { get :edit, :id => 42 }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context "PUT 'update'" do
    it "redirects to the organization's show page" do
      organization = FactoryGirl.create(:organization)
      sign_in_as(FactoryGirl.create(:cso_admin_user, :organization_id => organization.id))
      put :update, :id => organization.id
      response.should redirect_to organization_path(organization.id)
      flash[:notice].should be_present
    end

    it "updates the organization's name" do
      organization = FactoryGirl.create(:organization, :name => "Foo")
      sign_in_as(FactoryGirl.create(:cso_admin_user, :organization_id => organization.id))
      put :update, :id => organization.id, :organization => { :name => "Bar" }
      organization.reload.name.should == "Bar"
    end

    it "updates the organization's logo" do
      CarrierWave.configure { |c| c.storage = :file }
      organization = FactoryGirl.create(:organization, :logo => fixture_file_upload("/logos/logo.png"))
      sign_in_as(FactoryGirl.create(:cso_admin_user, :organization_id => organization.id))
      new_logo = fixture_file_upload("/logos/another_logo.jpg")
      put :update, :id => organization.id, :organization => { :logo => new_logo }
      organization.reload.logo.file.read.should == new_logo.read
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

      it "deactivates the organization" do
        organization = FactoryGirl.create(:organization)
        user = FactoryGirl.create(:cso_admin_user, :organization_id => organization.id)
        put :deactivate, :organization_id => organization.id
        organization.reload.should_not be_active
      end

      it "creates a delayed job to send an email" do
        organization = FactoryGirl.create(:organization)
        user = FactoryGirl.create(:cso_admin_user, :organization_id => organization.id)
        expect do
          put :deactivate, :organization_id => organization.id
        end.to change { Delayed::Job.where(:queue => "organization_deactivation_mail").count }.by(1)
      end

      it "sends an deactivation mail to the cso admin of the organization" do
        org = FactoryGirl.create(:organization)
        user = FactoryGirl.create(:cso_admin_user, :organization => org)
        put :deactivate, :organization_id => org.id
        Delayed::Worker.new.work_off
        ActionMailer::Base.deliveries.should_not be_empty
        email = ActionMailer::Base.deliveries.first
        email.to.should include(user.email)
      end

      it "redirects to the organizations index page with a flash notice" do
        org = FactoryGirl.create(:organization)
        user = FactoryGirl.create(:cso_admin_user, :organization_id => org.id)
        put :deactivate, :organization_id => org.id

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
