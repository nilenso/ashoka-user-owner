require 'spec_helper'

module Api
  module V1
    describe OrganizationsController do
      render_views

      before(:each) do
        token = stub(:accessible? => true)
        controller.stub(:doorkeeper_token) { token }
      end

      context "GET 'index'" do
        it "returns all the organizations which are active as JSON" do
          active_org_1 = FactoryGirl.create(:organization, :status => Organization::Status::ACTIVE)
          active_org_2 = FactoryGirl.create(:organization, :status => Organization::Status::ACTIVE)
          inactive_org = FactoryGirl.create(:organization, :status => Organization::Status::INACTIVE)
          get :index, :format => :json
          response.body.should == [active_org_1, active_org_2].to_json(:only => [:id, :name])
        end
        it "returns all the organizations which are active as JSON" do
          active_org_1 = FactoryGirl.create(:organization, :status => Organization::Status::ACTIVE)
          active_org_2 = FactoryGirl.create(:organization, :status => Organization::Status::ACTIVE)
          inactive_org = FactoryGirl.create(:organization, :status => Organization::Status::INACTIVE)
          get :index, :format => :json
          response.body.should == [active_org_1, active_org_2].to_json(:only => [:id, :name])
        end
      end

      context "GET 'validate_orgs" do
        it "returns true if all the ids exist in the user model" do
          organizations = FactoryGirl.create_list(:organization, 5)
          get :validate_orgs, :org_ids => organizations.map(&:id).to_json, :format => :json
        end

        it "returns false if one of the id doesn't exist in the user model" do
          organization = FactoryGirl.create(:organization)
          organizations = [1, 2, 3, organization.id]
          get :validate_orgs, :org_ids => organizations.to_json, :format => :json
          response.body.should == "false"
        end
      end

      context "GET 'show'" do
        it "returns the id of the organization" do
          organization = FactoryGirl.create(:organization)
          get :show, :id => organization.id, :format => :json
          organization_hash = JSON.parse(response.body)
          organization_hash['id'].should == organization.id
        end

        it "returns the name of the organization" do
          organization = FactoryGirl.create(:organization, :name => "Foo")
          get :show, :id => organization.id, :format => :json
          organization_hash = JSON.parse(response.body)
          organization_hash['name'].should == "Foo"
        end

        it "returns a bad request if the organization doesn't exist" do
          get :show, :id => 123, :format => :json
          response.should_not be_ok
        end

        context "for the organization logo" do
          it "returns a URL to the logo if it exists" do
            logo = fixture_file_upload("/logos/logo.png")
            organization = FactoryGirl.create(:organization, :logo => logo)
            get :show, :id => organization.id, :format => :json
            response_hash = JSON.parse(response.body)
            response_hash['logo_url'].should == organization.logo_url
          end

          it "returns a URL to a placeholder image if the logo doesn't exist" do
            organization = FactoryGirl.create(:organization, :logo => nil)
            get :show, :id => organization.id, :format => :json
            response_hash = JSON.parse(response.body)
            response_hash['logo_url'].should include "assets/placeholder_logo.png"
          end
        end
      end
    end
  end
end
