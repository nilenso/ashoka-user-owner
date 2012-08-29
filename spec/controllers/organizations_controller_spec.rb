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

      it "creates a new organization" do
        organization = FactoryGirl.attributes_for(:organization)
        expect { post :create, :organization => organization }.to change { Organization.count }.by(1)
      end

      it "redirects to root path with a flash message" do
        organization = { :name => "xuz", :users_attributes => [user] }
        post :create, :organization => organization
        response.should redirect_to(root_path)
        flash[:notice].should_not be_nil
      end

      it "makes the user created as the cso_admin for the organization" do
        organization = { :name => "xuz", :users_attributes => [user] }
        post :create, :organization => organization
        cso_admin = Organization.find_by_name(organization[:name]).users.first
        cso_admin.role.should == "cso_admin"
      end
    end

    context "when organization not created" do
      it "renders the new page" do
        post :create, :organization => { :users_attributes => [] }
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
      admin = FactoryGirl.create(:user, :role => "admin")
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

  context "PUT 'change_status' to approve" do
    it "approves the organization with a success message" do
      admin = FactoryGirl.create(:user, :role => "admin")
      sign_in_as(admin)

      org = FactoryGirl.create(:organization)
      FactoryGirl.create(:user, :email => "foo@bar.com", :organization => org)
      put :change_status, :organization_id => org.id, :status => "approved"
      org.reload

      org.should be_approved
      response.should redirect_to organizations_path
      flash[:notice].should_not be_nil
    end

    it "sends an approval mail to the cso admin of the organization" do
      admin = FactoryGirl.create(:user, :role => "admin")
      sign_in_as(admin)

      org = FactoryGirl.create(:organization)
      user = FactoryGirl.create(:user, :email => "foo@bar.com", :organization => org)
      put :change_status, :organization_id => org.id, :status => "approved"

      ActionMailer::Base.deliveries.should_not be_empty
      assigns(:email).to.join('').should == user.email
    end

    it "does not allow anyone other than admin to approve an organization" do
      org = FactoryGirl.create(:organization)
      put :change_status, :organization_id => org.id, :status => "approved"
      org.reload

      org.should_not be_approved
      response.should redirect_to login_path
      flash[:error].should_not be_nil
    end
  end

  context "PUT 'change_status' to reject" do
    it "rejects the organization with a success message" do
      admin = FactoryGirl.create(:user, :role => "admin")
      sign_in_as(admin)

      org = FactoryGirl.create(:organization)
      put :change_status, :organization_id => org.id, :status => "rejected"
      org.reload

      org.should be_rejected
      response.should redirect_to organizations_path
      flash[:notice].should_not be_nil
    end

    it "does not allow anyone other than admin to reject an organization" do
      org = FactoryGirl.create(:organization)
      put :change_status, :organization_id => org.id, :status => "rejected"
      org.reload

      org.should_not be_rejected
      response.should redirect_to login_path
      flash[:error].should_not be_nil
    end
  end
end