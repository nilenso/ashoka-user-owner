require 'spec_helper'

describe UsersController do
  before(:each) do
    user = FactoryGirl.build(:user)
    user.role = "cso_admin"
    user.save
    sign_in_as(user)
  end

  context "GET 'new'" do
    it "renders the 'new' template" do
      organization = FactoryGirl.create(:organization)
      get :new, :organization_id => organization.id
      
      response.should be_ok
      response.should render_template :new
    end

    it "assigns a blank user" do
      organization = FactoryGirl.create(:organization)
      get :new, :organization_id => organization.id
      assigns(:user).should be_a(User)
    end
  end

  context "POST 'create'" do
    it "creates a new user" do
      organization = FactoryGirl.create(:organization)
      user = FactoryGirl.attributes_for(:user)
      expect do
        post :create, :organization_id => organization.id, :user => user
      end.to change { User.count }.by(1)
    end

    it  "assigns an instance variable for the user" do
      organization = FactoryGirl.create(:organization)
      user = FactoryGirl.attributes_for(:user)
      post :create, :organization_id => organization.id, :user => user
      assigns(:user).should be_a(User)
    end

    it "assigns the proper organization ID for the user" do
      organization = FactoryGirl.create(:organization)
      user = FactoryGirl.attributes_for(:user)
      post :create, :organization_id => organization.id, :user => user
      User.last.organization_id.should == organization.id
    end

    it "assigns the role for the user as 'user'" do
      organization = FactoryGirl.create(:organization)
      user = FactoryGirl.attributes_for(:user)
      post :create, :organization_id => organization.id, :user => user
      User.last.role.should == 'user'
    end

    context "when save is successful" do
      it "should redirect to the root page" do 
        organization = FactoryGirl.create(:organization)
        user = FactoryGirl.attributes_for(:user)
        post :create, :organization_id => organization.id, :user => user
        response.should redirect_to(root_path)
      end
    end

    context "when save is unsuccessful" do
      it "should re-render the new page" do 
        organization = FactoryGirl.create(:organization)
        user = FactoryGirl.attributes_for(:user).delete('name')
        post :create, :organization_id => organization.id, :user => user
        response.should render_template(:new)
      end
    end
  end
end
