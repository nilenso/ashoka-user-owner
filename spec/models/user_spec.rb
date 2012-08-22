require 'spec_helper'

describe User do
  it { should respond_to(:email) }
  it { should respond_to(:name) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }

  context "validations" do
    it { should validate_presence_of(:email)}
    it { should validate_presence_of(:name)}
    it { should validate_presence_of(:password_digest)}    
  end
end