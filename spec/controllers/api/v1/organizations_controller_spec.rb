require 'spec_helper'

module Api
  module V1
    describe OrganizationsController do
      render_views

      it "returns all the organizations which are approved as JSON" do
        token = stub(:accessible? => true)
        controller.stub(:doorkeeper_token) { token }

        approved_org_1 = FactoryGirl.create(:organization, :status => "approved")
        approved_org_2 = FactoryGirl.create(:organization, :status => "approved")
        not_approved_org = FactoryGirl.create(:organization)
        get :index, :format => :json
        response.body.should == [approved_org_1, approved_org_2].to_json(:only => [:id, :name])
      end
    end
  end
end
