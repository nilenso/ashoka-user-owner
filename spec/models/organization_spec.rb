require 'spec_helper'

describe Organization do
  it { should have_many(:users) }
  it { should accept_nested_attributes_for(:users) }
  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }
  it { should respond_to(:status) }

  context "Logic" do
    it "checks if the organization is approved or not" do
      org = FactoryGirl.create(:organization)
      org.should_not be_approved
      org.status = "approved"
      org.should be_approved
    end

    it "checks if the organization is rejected or not" do
      org = FactoryGirl.create(:organization)
      org.should_not be_rejected
      org.status = "rejected"
      org.should be_rejected
    end
  end
end