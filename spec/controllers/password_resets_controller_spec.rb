require 'spec_helper'

describe PasswordResetsController do

  context "GET 'new'" do
    it "renders a page to reset the password" do
      get :new
      response.should be_ok
      response.should render_template('new')
    end
  end

  context "PUT 'edit'" do
    it "renders the page to edit the password the reset token" do
      user = FactoryGirl.create(:user)
      user.generate_password_reset_token
      put :edit, :id => user.password_reset_token
      response.should be_ok
      response.should render_template('edit')
    end
  end
end
