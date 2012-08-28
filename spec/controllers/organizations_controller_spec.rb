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
end