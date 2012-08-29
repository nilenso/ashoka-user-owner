require 'spec_helper'

describe Organization do
	it { should have_many(:users) }
	it { should accept_nested_attributes_for(:users) }
  it { should validate_presence_of(:name) }
  it { should respond_to(:status) }

  context "Logic" do
    it "checks if the organization is approved" do
      org = FactoryGirl.create(:organization)
      org.should_not be_approved
    end
  end
end