require 'spec_helper'

describe PasswordResetsController do

  context "GET 'new'" do
    it "renders a page to reset to generate a reset password token" do
      get :new
      response.should be_ok
      response.should render_template('new')
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
        user = User.find_by_password_reset_token(user.password_reset_token)
        user.authenticate(user_password[:password]).should be_true
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
