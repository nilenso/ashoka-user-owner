require 'spec_helper'

describe PasswordResetsController do

  context "GET 'new'" do
    it "renders a page to reset to generate a reset password token" do
      get :new
      response.should be_ok
      response.should render_template('new')
    end
  end

  context "POST 'create'" do
    context "when user exists" do
      it "creates the password with the new one" do
        org = FactoryGirl.create(:organization)
        user = FactoryGirl.create(:user, :password_reset_token => nil, :organization => org)
        post :create, :email => user.email
        response.should be_redirect
        user.reload.password_reset_token.should_not be_nil
        flash[:notice].should_not be_nil
      end

      it "sends an email to user" do
        ActionMailer::Base.deliveries.clear
        org = FactoryGirl.create(:organization)
        user = FactoryGirl.create(:user, :password_reset_token => nil, :organization => org)
        post :create, :email => user.email
        ActionMailer::Base.deliveries.should_not be_empty
        email = ActionMailer::Base.deliveries.first
        email.to.should include(user.email)
      end

      it "renders the reset password page with error if user is inactive" do
        org = FactoryGirl.create(:organization)
        user = FactoryGirl.create(:user, :password_reset_token => nil,
                                  :organization => org, :status => User::Status::INACTIVE)
        post :create, :email => user.email
        response.should redirect_to new_password_reset_path
        flash[:error].should_not be_nil
      end
    end

    context "when user doesn't exist" do
      it "renders the reset password page again" do
        post :create, :email => "xyz@abc.com"
        response.should redirect_to new_password_reset_path
        flash[:error].should_not be_nil
      end
    end
  end

  context "GET 'edit'" do
    it "renders the page to change the password using reset password token" do
      user = FactoryGirl.create(:user)
      user.generate_password_reset_token
      get :edit, :id => user.password_reset_token
      assigns(:user).should_not be_nil
      response.should be_ok
      response.should render_template('edit')
    end
  end

  context "PUT 'update'" do
    context "when save is successful" do
      it "updates the password with the new one" do
        user = FactoryGirl.create(:user)
        user.generate_password_reset_token
        user_password = { :password => "xyz", :password_confirmation => "xyz" }
        put :update, :id => user.password_reset_token, :user  => user_password
        response.should be_redirect
        user = User.find(user)
        user.authenticate(user_password[:password]).should be_true
        flash[:notice].should_not be_nil
      end

      it "resets the session" do
        user = FactoryGirl.create(:user)
        sign_in_as(user)
        user.generate_password_reset_token
        user_password = { :password => "xyz", :password_confirmation => "xyz" }
        put :update, :id => user.password_reset_token, :user  => user_password
        response.should be_redirect
        controller.current_user.should be_nil
      end

      it "deletes the password reset token after the reset" do
        user = FactoryGirl.create(:user)
        user.generate_password_reset_token
        user_password = { :password => "xyz", :password_confirmation => "xyz" }
        put :update, :id => user.password_reset_token, :user  => user_password
        response.should be_redirect
        User.find(user).password_reset_token.should be_nil
      end
    end

    context "when save unsuccessful" do
      it "renders the reset password page again" do
        user = FactoryGirl.create(:user)
        user.generate_password_reset_token
        user_password = {}
        put :update, :id => user.password_reset_token, :user  => user_password
        response.should be_ok
        response.should render_template('edit')
      end
    end
  end
end
