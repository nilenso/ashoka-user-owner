require 'spec_helper'

describe User do
  it { should respond_to(:email) }
  it { should respond_to(:name) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should belong_to(:organization) }

  context "validations" do
    subject { FactoryGirl.create(:user) }
    it { should validate_presence_of(:email)}
    it { should validate_presence_of(:name)}
    it { should validate_presence_of(:password_digest)}
    it { should validate_uniqueness_of(:email) }
  end
end
