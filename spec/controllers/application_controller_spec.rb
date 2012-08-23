require 'spec_helper'

describe ApplicationController do
  controller do
    def index
      render :nothing => true
    end
  end

  it "returns the current user" do
    user = FactoryGirl.create(:user)
    sign_in_as user
    controller.current_user.should == user
  end

  it "checkes if user is signed in or not" do
    user = FactoryGirl.create(:user)
    controller.should_not have_signed_in_user
    sign_in_as user
    controller.should have_signed_in_user
  end
end