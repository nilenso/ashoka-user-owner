require 'spec_helper'

module Api
  module V1
    describe OrganizationsController do
      render_views

      before(:each) do
        token = stub(:accessible? => true)
        controller.stub(:doorkeeper_token) { token }
      end

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

      it "returns true if all the ids exist in the user model" do
        organizations = FactoryGirl.create_list(:organization, 5)
        get :validate_orgs, :org_ids => organizations.map(&:id).to_json, :format => :json
      end

      it "returns false if one of the id doesn't exist in the user model" do
        organization = FactoryGirl.create(:organization)
        organizations = [1,2,3, organization.id]
        get :validate_orgs, :org_ids => organizations.to_json, :format => :json
        response.body.should == "false"
      end
    end
  end
end
