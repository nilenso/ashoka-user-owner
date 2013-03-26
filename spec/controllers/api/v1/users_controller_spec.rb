require 'spec_helper'

module Api
  module V1
    describe UsersController do
      render_views

      it "returns all the info for the logged in user in JSON excluding password" do
        organization = FactoryGirl.create(:organization, :org_type => "CSO")
        user = FactoryGirl.create(:user, :organization => organization)
        token = stub(:accessible? => true)
        controller.stub(:current_user) { user }
        controller.stub(:doorkeeper_token) { token }
        get :me, :format => :json
        response.body.should == user.to_json(:except => :password_digest,
                                            :include => { :organization => { :only => :org_type }})
      end

      context "when asking for users of the organization " do
        before(:each) do
          @organization = FactoryGirl.create(:organization, :org_type => "CSO")
          @cso_admin = FactoryGirl.create(:cso_admin_user, :organization => @organization, :status => User::Status::ACTIVE)
          @user = FactoryGirl.create(:user, :organization => @organization, :role => 'user', :status => User::Status::ACTIVE)
          @another_user = FactoryGirl.create(:user, :organization => @organization, :role => 'user', :status => User::Status::ACTIVE)
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
          JSON.parse(response.body).length.should == @organization.users.size
        end

        it "returns names and ids for specific users of an organization if their user_ids are given" do
          controller.stub(:current_user) { @cso_admin }
          get :index, :organization_id => @organization.id, :user_ids => [@another_user.id.to_s], :format => :json
          response.body.should include @another_user.to_json(:only => [:id, :name, :role])
          response.body.should_not include @user.to_json(:only => [:id, :name, :role])
        end
      end

      context "given user ids" do
        before(:each) do
          @organization = FactoryGirl.create(:organization)
          @cso_admin = FactoryGirl.create(:cso_admin_user, :organization => @organization)
          controller.stub(:current_user) { @cso_admin }
          token = stub(:accessible? => true)
          controller.stub(:doorkeeper_token) { token }
      end

        it "returns the names and ids of users" do
          users = FactoryGirl.create_list(:user, 5)
          get :names_for_ids, :user_ids => users.map(&:id).to_json, :format => :json
          JSON.parse(response.body).should =~ users.map {|user| {:id => user.id, :name => user.name} }.as_json
        end

        it "returns true if all the ids exist in the user model" do
          users = FactoryGirl.create_list(:user, 5)
          get :validate_users, :user_ids => users.map(&:id).to_json, :format => :json
          response.body.should == "true"
        end

        it "returns false if one of the id doesn't exist in the user model" do
          user = FactoryGirl.create(:user)
          users = [1,2,3, user.id]
          get :validate_users, :user_ids => users.to_json, :format => :json
          response.body.should == "false"
        end

        it "returns a bad response if not logged in" do
          controller.stub(:current_user) { nil }
          users = [1,2,3]
          expect { get :validate_users, :user_ids => users.to_json, :format => :json }.
              to raise_error(CanCan::AccessDenied)
        end
      end
    end
  end
end
