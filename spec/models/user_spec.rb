require 'spec_helper'

describe User do
  context "validations" do
    it "validates presence of password and password confirmation on create" do
      organization = FactoryGirl.create(:organization)
      user = FactoryGirl.build(:user, :organization => organization)
      user.password = nil
      user.should_not be_valid
    end

    it "doesn't allow an invalid role" do
      user = FactoryGirl.build(:super_admin_user, :role => 'xyz')
      user.should_not be_valid
    end

    it "validates uniqueness of email with case insensitive" do
      user = FactoryGirl.create(:user, :email => "abc@test.com")
      another_user = FactoryGirl.build(:user)
      another_user.email = "Abc@test.com"
      another_user.should_not be_valid
    end
  end

  context "scopes" do
    it "returns the super admins" do
      super_admin_user = FactoryGirl.create(:super_admin_user)
      cso_admin_user = FactoryGirl.create(:cso_admin_user)
      User.super_admins.should == [super_admin_user]
    end

    it "returns the list of super admins and cso admins for that organization" do
      super_admin = FactoryGirl.create(:super_admin_user)
      cso_admin = FactoryGirl.create(:cso_admin_user)
      field_agent = FactoryGirl.create(:field_agent_user)
      organization = FactoryGirl.create(:organization, :users => [super_admin, cso_admin, field_agent])
      User.super_admins_and_cso_admins_for(organization.id).should =~ [super_admin, cso_admin]
    end
  end

  context "logic" do
    roles = User::ROLES

    roles.each do |role|
      it "checks if the user is a #{role}" do
        user = FactoryGirl.create(:user, :organization => FactoryGirl.create(:organization))
        user.update_column :role, role
        user.should send("be_#{role}")
      end
    end

    it "checks if the user is active" do
      user = FactoryGirl.create(:user, :status => User::Status::ACTIVE)
      another_user = FactoryGirl.create(:user, :status => User::Status::INACTIVE)
      user.should be_active
      another_user.should_not be_active
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

    it "sets password reset token and password token sent at parameters" do
      user.send_password_reset
      user.reload.password_reset_token.should_not be_nil
    end

    it "creates a delayed job to send an email" do
      expect { user.send_password_reset }.to change { Delayed::Job.where(:queue => "password_reset_mail").count }.by(1)
    end

    it "sends a email to the user with the password token " do
      user.send_password_reset
      Delayed::Worker.new.work_off
      ActionMailer::Base.deliveries.should_not be_empty
      email = ActionMailer::Base.deliveries.last
      email.to.should include(user.email)
    end

    it "generates a random password" do
      user = FactoryGirl.create(:user, :password => "xyz", :password_confirmation => "xyz")
      user.generate_password
      user.authenticate("xyz").should be_false
    end

    it "changes the status from pending  to active if the password is reset" do
      user = FactoryGirl.create(:user, :status => User::Status::PENDING, :organization => org)
      user.generate_password_reset_token
      user.status.should == User::Status::PENDING
      user.reset_password("xyz","xyz")
      user.status.should == User::Status::ACTIVE
    end
  end

  context "default values" do
    it "sets the default role to 'field_agent'" do
      user = User.create(:name => 'John', :email => 'abc@abc.com', :password => 'abc', :password_confirmation => 'abc')
      user.reload.role.should == 'field_agent'
    end
    it "sets the default status to 'pending'" do
      user = User.create(:name => 'John', :email => 'abc@abc.com', :password => 'abc', :password_confirmation => 'abc')
      user.reload.status.should == User::Status::PENDING
    end
  end

  it "converts the user email to downcase before saving" do
    user = FactoryGirl.build(:user, :email => "ABC@test.com", :organization => FactoryGirl.create(:organization))
    user.save
    user.reload.email.should == "abc@test.com"
  end

  it "returns only the active users" do
    FactoryGirl.create(:user, :status => User::Status::PENDING)
    user = FactoryGirl.create(:user, :status => User::Status::ACTIVE)
    User.active_users.should include(user)
  end

  it "returns only the inactive users" do
    FactoryGirl.create(:user, :status => User::Status::PENDING)
    FactoryGirl.create(:user, :status => User::Status::ACTIVE)
    user = FactoryGirl.create(:user, :status => User::Status::INACTIVE)
    User.inactive_users.should == [user]
  end

  it "returns only the pending users" do
    user = FactoryGirl.create(:user, :status => User::Status::PENDING)
    FactoryGirl.create(:user, :status => User::Status::ACTIVE)
    FactoryGirl.create(:user, :status => User::Status::INACTIVE)
    User.pending_users.should == [user]
  end

  it "returns true if users exists for given user_ids" do
    user = FactoryGirl.create(:user)
    another_user = FactoryGirl.create(:user)
    User.valid_ids?([user, another_user]).should be_true
  end

  it "returns false if a user doesn't exist for given user_ids" do
    user = FactoryGirl.create(:user)
    User.valid_ids?([user, 3]).should be_false
  end

  context "when fetching a list of available roles that a user is allowed to create" do
    it "includes all roles for an super_admin user" do
      user = FactoryGirl.create(:super_admin_user)
      user.available_roles.should == User::ROLES
    end

    it "does not include 'super_admin' for other users" do
      user = FactoryGirl.create(:cso_admin_user)
      user.available_roles.should_not include "super_admin"
    end
  end

  context "#maybe" do
    it "returns the user that was passed in if it exists" do
      user = stub
      User.maybe(user).should == user
    end

    it "returns a NullUser if the passed in user doesn't exist" do
      User.maybe(nil).should be_a NullUser
    end
  end

  it_behaves_like "a soft-deletable element"
end
