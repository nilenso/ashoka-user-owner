require 'spec_helper'

module Api
  module V1
    describe UsersController do
      render_views

      it "returns all the info for a User in JSON excluding password" do
        user = FactoryGirl.create(:user)
        token = stub(:accessible? => true)
        controller.stub(:current_user) { user }
        controller.stub(:doorkeeper_token) { token }
        
        get :show, :format => :json
        response.body.should == user.to_json(:except => :password_digest)
      end
    end
  end
end
