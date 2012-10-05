require 'spec_helper'

describe User do
  it { should respond_to(:email) }
  it { should respond_to(:name) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should belong_to(:organization) }

  context "validations" do
    subject { FactoryGirl.create(:admin_user, :organization => FactoryGirl.create(:organization)) }

    it { should validate_presence_of(:email)}
    it { should validate_presence_of(:name)}
    it { should validate_presence_of(:password)}
    it { should validate_presence_of(:password_confirmation)}
    it { should validate_uniqueness_of(:email) }

    it "doesn't allow an invalid role" do
      user = FactoryGirl.build(:admin_user, :role => 'xyz')
      user.should_not be_valid
    end
  end

  context "logic" do
    it "checks if user is an admin" do
      user = FactoryGirl.build(:admin_user, :organization => FactoryGirl.create(:organization))
      user.should_not be_admin
      user.role = 'admin'
      user.save
      user.should be_admin
    end
  end

  context "password reset" do
    let(:org) { FactoryGirl.create(:organization) }
    let(:user) { FactoryGirl.create(:user, :organization => org) }

    it "generates a password reset token" do
      user.generate_password_reset_token
      user.reload.password_reset_token.should_not be_nil
    end

    it "resets the password to password provided" do
      user.generate_password_reset_token
      user.reset_password("xyz","xyz")
      user.reload.password_reset_token.should be_nil
      user.authenticate("xyz").should be_true
    end

    it "sets a password reset token" do
      user.send_password_reset
      user.reload.password_reset_token.should_not be_nil
    end

    it "sends a email to the user with the password token " do
      user.send_password_reset
      ActionMailer::Base.deliveries.should_not be_empty
      email = ActionMailer::Base.deliveries.last
      email.to.should include(user.email)
    end

    it "generates a random password" do
      user = FactoryGirl.create(:user, :password => "xyz", :password_confirmation => "xyz")
      user.generate_password
      user.authenticate("xyz").should be_false
    end

    it "changes the status from pending  to accepted if the password is reset" do
      user = FactoryGirl.create(:user, :status => User::Status::PENDING, :organization => org)
      user.generate_password_reset_token
      user.status.should == User::Status::PENDING
      user.reset_password("xyz","xyz")
      user.status.should == User::Status::ACCEPTED
    end
  end

  context "default values" do
    it "sets the default role to 'user'" do
      user = User.create(:name => 'John', :email => 'abc@abc.com', :password => 'abc', :password_confirmation => 'abc')
      user.reload.role.should == 'user'
    end
    it "sets the default status to 'pending'" do
      user = User.create(:name => 'John', :email => 'abc@abc.com', :password => 'abc', :password_confirmation => 'abc')
      user.reload.status.should == User::Status::PENDING
    end
  end
end
