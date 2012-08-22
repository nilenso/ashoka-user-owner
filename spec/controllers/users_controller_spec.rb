require 'spec_helper'

describe UsersController do
  render_views

  context "GET 'new'" do
    it "renders a sign up page for the user" do
      get :new
      response.should be_ok
      response.should render_template('new')
      assigns(:user).should_not be_nil
    end
  end
  
  context "POST 'create'" do
    context "when user created successfully" do
      it "creates a new user" do
        user = FactoryGirl.attributes_for(:user)
        expect { post :create, :user => user }.to change { User.count }.by(1)
      end

      it "redirects to root path with a flash message" do
        user = FactoryGirl.attributes_for(:user)
        post :create, :user => user
        response.should redirect_to(root_path)
        flash[:notice].should_not be_nil
      end
    end

    context "when user not created " do
      it "renders the new page" do
        post :create, :user => {}
        response.should render_template('new')
        flash[:error].should_not be_nil
      end
    end
  end
end
