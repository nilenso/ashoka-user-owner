require 'spec_helper'

module Api
  module V1
    describe UsersController do
      render_views

      it "returns all the info for the logged in user in JSON excluding password" do
        user = FactoryGirl.create(:user)
        token = stub(:accessible? => true)
        controller.stub(:current_user) { user }
        controller.stub(:doorkeeper_token) { token }
        get :me, :format => :json
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
          response.body.should include @user.to_json(:only => [:id, :name, :role])
          response.body.should include @cso_admin.to_json(:only => [:id, :name, :role])
        end

        it "for a normal user returns only his information" do
          controller.stub(:current_user) { @user }
          get :index, :organization_id => @organization.id, :format => :json
          response.body.should include @user.to_json(:only => [:id, :name, :role])
          JSON.parse(response.body).length.should == 1
        end

        it "returns names and ids for specific users of an organization if their user_ids are given" do
          controller.stub(:current_user) { @cso_admin }
          get :index, :organization_id => @organization.id, :user_ids => [@another_user.id.to_s], :format => :json
          response.body.should include @another_user.to_json(:only => [:id, :name, :role])
          response.body.should_not include @user.to_json(:only => [:id, :name, :role])
        end
      end

      it "returns the names and ids of users for all the ids passed in " do
        @organization = FactoryGirl.create(:organization)
        @cso_admin = FactoryGirl.create(:cso_admin_user, :organization => @organization)
        controller.stub(:current_user) { @cso_admin }
        token = stub(:accessible? => true)
        controller.stub(:doorkeeper_token) { token }
        users = FactoryGirl.create_list(:user, 5)
        get :names_for_ids, :user_ids => users.map(&:id).to_json, :format => :json
        response.body.should include users.map {|user| {:id => user.id, :name => user.name} }.to_json
      end
    end
  end
end
