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
    it { should validate_presence_of(:password_digest)}
    it { should validate_uniqueness_of(:email) }

    context "user is not an admin" do
      it { should validate_presence_of(:organization_id) }
    end

    context "user is an admin" do
      subject { FactoryGirl.create(:user, :role => 'admin')}
      it { should_not validate_presence_of(:organization_id) }
    end

  end
end
