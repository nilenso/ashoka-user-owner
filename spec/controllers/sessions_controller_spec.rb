require 'spec_helper'

describe SessionsController do
  context "GET 'new'" do
    it "renders the login page" do
      get :new
      response.should be_ok
      response.should render_template('new')
    end
  end

  context "POST 'create'" do
    context "user exists" do
      let(:user) { FactoryGirl.create(:user) }
      context "email/password combination is correct" do
        it "logs in the user" do
          post :create, :user => { :email => user.email, :password => user.password }
          response.should redirect_to(root_path)
          session[:user_id].should == user.id
        end
      end
    end
    
    context "user doesn't exist or email/password combination is incorrect" do
      it "redirects to the login page with a flash error" do
        post :create, :user => { :email => "foo@bar.com", :password => "" }
        response.should render_template('new')
        flash[:error].should_not be_nil
      end
    end
  end

  context "DELETE 'destroy'" do
    it "logs out the current user and redirects to login page" do
      delete :destroy
      response.should redirect_to(login_path)
      session[:user_id].should be_nil
    end
  end
end