require 'spec_helper'

describe StaticPagesController do
  context "when testing the home page" do
    it "responds to the home page action" do
      get :home
      response.should be_ok
      response.should render_template(:home)
    end
  end
end
