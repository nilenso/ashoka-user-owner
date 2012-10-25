require 'spec_helper'

module Api
  module V1
    describe OrganizationsController do
      render_views

      it "returns all the organizations which are active as JSON" do
        token = stub(:accessible? => true)
        controller.stub(:doorkeeper_token) { token }

        active_org_1 = FactoryGirl.create(:organization, :status => Organization::Status::ACTIVE)
        active_org_2 = FactoryGirl.create(:organization, :status => Organization::Status::ACTIVE)
        inactive_org = FactoryGirl.create(:organization, :status => Organization::Status::INACTIVE)
        get :index, :format => :json
        response.body.should == [active_org_1, active_org_2].to_json(:only => [:id, :name])
      end
      it "returns all the organizations which are active as JSON" do
        token = stub(:accessible? => true)
        controller.stub(:doorkeeper_token) { token }

        active_org_1 = FactoryGirl.create(:organization, :status => Organization::Status::ACTIVE)
        active_org_2 = FactoryGirl.create(:organization, :status => Organization::Status::ACTIVE)
        inactive_org = FactoryGirl.create(:organization, :status => Organization::Status::INACTIVE)
        get :index, :format => :json
        response.body.should == [active_org_1, active_org_2].to_json(:only => [:id, :name])
      end
    end
  end
end
