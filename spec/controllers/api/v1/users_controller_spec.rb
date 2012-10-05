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

      context "when asking for users of the organization " do
        before(:each) do
          @organization = FactoryGirl.create(:organization)
          @cso_admin = FactoryGirl.create(:cso_admin_user, :organization => @organization)
          @user = FactoryGirl.create(:user, :organization => @organization, :role => 'user')
          @another_user = FactoryGirl.create(:user, :organization => @organization, :role => 'user')
          token = stub(:accessible? => true)
          controller.stub(:doorkeeper_token) { token }
        end

        it "returns names and ids for the users of the current_user's organization in JSON" do
          controller.stub(:current_user) { @cso_admin }
          get :index, :organization_id => @organization.id, :format => :json
          response.body.should include @user.to_json(:only => [:id, :name])
          response.body.should_not include @cso_admin.to_json(:only => [:id, :name])
        end

        it "doesn't allow a normal user" do
          controller.stub(:current_user) { @user }
          get :index, :organization_id => @organization.id, :format => :json
          response.body.should include "not authorized"
        end

        it "returns names and ids for specific users of an organization if their user_ids are given" do
          controller.stub(:current_user) { @cso_admin }
          get :index, :organization_id => @organization.id, :user_ids => [@another_user.id.to_s], :format => :json
          response.body.should include @another_user.to_json(:only => [:id, :name])
          response.body.should_not include @user.to_json(:only => [:id, :name])
        end
      end
    end
  end
end
