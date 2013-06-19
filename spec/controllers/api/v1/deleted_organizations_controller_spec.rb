require 'spec_helper'

describe Api::V1::DeletedOrganizationsController do
  describe "GET 'index'" do
    it "returns the IDs of all soft-deleted organizations" do
      organization = FactoryGirl.create(:organization)
      deleted_organization = FactoryGirl.create(:organization, :deleted_at => 5.days.ago)
      get :index
      JSON.parse(response.body).should == [deleted_organization.id]
    end
  end
end
