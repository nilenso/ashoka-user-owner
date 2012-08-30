require 'spec_helper'

describe ApplicationController do
  controller do
    # mocking index action for testing locale
    def index
      redirect_to root_path
    end
  end

  context "when setting the locale based on params" do
    after(:each) { I18n.locale = I18n.default_locale }

    it "should set locale to french if params[:locale] is fr" do
      get :index, :locale => 'fr'
      I18n.locale.should == :fr
    end
  end

  context "when generating paths without passing the locale" do
    it "sets the locale param to fr when the locale is fr" do
      I18n.locale = 'fr'
      register_path.should match /fr.*/
    end

    it "doesn't set the locale param when the locale is en" do
      I18n.locale = 'en'
      register_path.should_not match /en.*/
    end
  end

  it "returns the current user" do
    user = FactoryGirl.create(:user)
    sign_in_as user
    controller.current_user.should == user
  end

  it "checks if user is signed in or not" do
    user = FactoryGirl.create(:user)
    controller.should_not have_signed_in_user
    sign_in_as user
    controller.should have_signed_in_user
  end
end