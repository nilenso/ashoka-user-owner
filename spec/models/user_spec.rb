require 'spec_helper'

describe User do
  it { should respond_to(:email) }
  it { should respond_to(:name) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should belong_to(:organization) }

  context "validations" do
    subject { FactoryGirl.create(:user, :organization => FactoryGirl.create(:organization)) }
    it { should validate_presence_of(:email)}
    it { should validate_presence_of(:name)}
    it { should validate_presence_of(:password)}
    it { should validate_presence_of(:password_confirmation)}
    it { should validate_uniqueness_of(:email) }
  end

  context "logic" do
    it "checks if user is an admin" do
      user = FactoryGirl.create(:user, :organization => FactoryGirl.create(:organization))
      user.should_not be_admin
      user.role = 'admin'
      user.save
      user.should be_admin
    end
  end
end
