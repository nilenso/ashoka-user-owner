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
    it "lists all the organizations" do
      get :index
      response.should redirect_to(login_path)
    end

    it "can be accessed by the admin" do
      admin = FactoryGirl.create(:admin_user, :role => "admin")
      sign_in_as(admin)
      get :index
      response.should be_ok
      assigns(:organizations).should_not be_nil
    end

    it "can not be accessed by anyone other than admin" do
      not_admin = FactoryGirl.create(:user)
      sign_in_as(not_admin)
      get :index
      response.should redirect_to(root_path)
      flash[:error].should_not be_nil
    end
  end

  context "PUT 'approve'" do
    context "when admin is logged in" do
      before(:each) do
        admin = FactoryGirl.create(:admin_user)
        sign_in_as(admin)
        ActionMailer::Base.deliveries.clear
      end

      it "sends an approval mail to the cso admin of the organization" do
        org = FactoryGirl.create(:organization)
        user = FactoryGirl.create(:cso_admin_user, :organization => org)
        put :approve, :organization_id => org.id
        ActionMailer::Base.deliveries.should_not be_empty
        email = ActionMailer::Base.deliveries.first
        email.to.should include(user.email)
        response.should be_redirect
        org.reload.should be_approved
      end

      it "approves the organization with a flash notice" do
        org = FactoryGirl.create(:organization)
        user = FactoryGirl.create(:cso_admin_user, :organization_id => org.id)
        put :approve, :organization_id => org.id

        org.reload.should be_approved
        response.should redirect_to organizations_path
        flash[:notice].should_not be_nil
      end
    end

    context "when not logged in" do
      it "does not allow anyone other than admin to approve an organization" do
        org = FactoryGirl.create(:organization)
        put :approve, :organization_id => org.id

        org.reload.should_not be_approved
        response.should redirect_to login_path
        flash[:error].should_not be_nil
      end
    end
  end

  context "PUT 'reject'" do
    context "when admin is logged in" do
      before(:each) do
        admin = FactoryGirl.create(:admin_user)
        sign_in_as(admin)
        ActionMailer::Base.deliveries.clear
      end

      it "sends an rejection mail to the cso admin of the organization" do
        org = FactoryGirl.create(:organization)
        user = FactoryGirl.create(:cso_admin_user, :organization => org)
        put :reject, :organization_id => org.id
        ActionMailer::Base.deliveries.should_not be_empty
        email = ActionMailer::Base.deliveries.first
        email.to.should include(user.email)
        org.reload.should_not be_approved
      end

      it "rejects the organization with a flash notice" do
        org = FactoryGirl.create(:organization)
        user = FactoryGirl.create(:cso_admin_user, :organization_id => org.id)
        put :reject, :organization_id => org.id

        org.reload.should_not be_approved
        response.should redirect_to organizations_path
        flash[:notice].should_not be_nil
      end
    end

    context "when not logged in" do
      it "does not allow anyone other than admin to reject an organization" do
        org = FactoryGirl.create(:organization)
        put :reject, :organization_id => org.id

        org.reload.should_not be_approved
        response.should redirect_to login_path
        flash[:error].should_not be_nil
      end
    end
  end
end
