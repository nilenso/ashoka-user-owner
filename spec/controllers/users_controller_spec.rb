require 'spec_helper'

describe UsersController do
  before(:each) do
    @organization = FactoryGirl.create(:organization)
    user = FactoryGirl.build(:user)
    user.role = "cso_admin"
    user.organization_id = @organization.id
    user.save
    sign_in_as(user)
  end

  context "GET 'new'" do
    it "renders the 'new' template" do
      get :new, :organization_id => @organization.id

      response.should be_ok
      response.should render_template :new
    end

    it "assigns a blank user" do

      get :new, :organization_id => @organization.id
      assigns(:user).should be_a(User)
    end
  end

  context "GET 'index'" do
    it "renders the 'index' template" do
      get :index, :organization_id => @organization.id

      response.should be_ok
      response.should render_template :index
    end
    it "lists all the user of the given organization" do
      user = FactoryGirl.create(:user, :organization => @organization, :role => 'user')
      another_user = FactoryGirl.create(:cso_admin_user, :organization => @organization)
      get :index, :organization_id => @organization
      response.should be_ok
      assigns(:users).should include user
      assigns(:users).should_not include another_user
    end
  end

  context "POST 'create'" do

    it  "assigns an instance variable for the user" do

      user = FactoryGirl.attributes_for(:user)
      post :create, :organization_id => @organization.id, :user => user
      assigns(:user).should be_a(User)
    end

    context "when save is successful" do
      it "creates a new user" do

        user = FactoryGirl.attributes_for(:user)
        expect do
          post :create, :organization_id => @organization.id, :user => user
        end.to change { User.count }.by(1)
      end

      it "assigns the proper organization ID for the user" do

        user = FactoryGirl.attributes_for(:user)
        post :create, :organization_id => @organization.id, :user => user
        User.last.organization_id.should == @organization.id
      end

      it "assigns the role for the user as 'user'" do

        user = FactoryGirl.attributes_for(:user)
        post :create, :organization_id => @organization.id, :user => user
        User.last.role.should == 'user'
      end

      it "assigns a random password for the user" do
        user = {:name => "foo", :email => "smittty@baz.com", :password => "123", :password_confirmation => "123"}
        post :create, :organization_id => @organization.id, :user => user
        User.find_by_email("smittty@baz.com").authenticate("123").should be_false
      end

      it "assigns the status for the user as 'pending'" do

        user = FactoryGirl.attributes_for(:user)
        post :create, :organization_id => @organization.id, :user => user
        User.last.status.should == User::Status::PENDING
      end

      it "should redirect to the root page" do

        user = FactoryGirl.attributes_for(:user)
        post :create, :organization_id => @organization.id, :user => user
        response.should redirect_to(root_path)
        flash[:notice].should_not be_nil
      end

      it "generates a password token at creation of user" do
        user = FactoryGirl.attributes_for(:user)
        post :create, :organization_id => @organization.id, :user => user
        User.find_by_email(user[:email]).password_reset_token.should_not be_nil
      end

      it "sends a mail to given user with password link" do
        ActionMailer::Base.deliveries.clear
        user = FactoryGirl.attributes_for(:user)
        post :create, :organization_id => @organization.id, :user => user
        ActionMailer::Base.deliveries.should_not be_empty
        email = ActionMailer::Base.deliveries.first
        email.to.should include(user[:email])
      end
    end

    context "when save is unsuccessful" do
      it "should re-render the new page" do

        user = FactoryGirl.attributes_for(:user).delete('name')
        post :create, :organization_id => @organization.id, :user => user
        response.should render_template(:new)
      end
    end

    context "when authenticating" do
      it "allows a CSO admin to create an user" do
        user = FactoryGirl.build(:user)
        user.role = "cso_admin"
        user.organization_id = @organization.id
        user.save
        sign_in_as(user)


        new_user = FactoryGirl.attributes_for(:user).delete('name')
        post :create, :organization_id => @organization.id, :user => new_user
        response.should be_ok
      end

      it "does not allow a CSO admin from another organization to create an user" do
        another_organization = FactoryGirl.create(:organization)

        user = FactoryGirl.build(:user)
        user.role = "cso_admin"
        user.organization_id = another_organization.id
        user.save
        sign_in_as(user)

        new_user = FactoryGirl.attributes_for(:user).delete('name')
        post :create, :organization_id => @organization.id, :user => new_user
        response.should_not be_ok
      end

      it "does not allow the sysadmin to create a user" do
        user = FactoryGirl.build(:user)
        user.role = "admin"
        user.organization_id = nil
        user.save
        sign_in_as(user)

        new_user = FactoryGirl.attributes_for(:user).delete('name')
        post :create, :organization_id => @organization.id, :user => new_user
        response.should_not be_ok
      end
    end
  end
end
