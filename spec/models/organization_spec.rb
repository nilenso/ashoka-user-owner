require 'spec_helper'

describe Organization do
  subject { FactoryGirl.create(:organization) }
  it { should have_many(:users) }
  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }
  it { should respond_to(:status) }
  it { should respond_to(:default_locale) }

  context "callbacks" do
    it "sends emails to superadmins when an organization that allows sharing is created" do
      expect do
        FactoryGirl.create(:organization, :allow_sharing => true)
      end.to change { Delayed::Job.where(:queue => "allow_sharing_email").count }.by(1)
    end

    it "doesn't send an email when an organization that doesn't allow sharing is created" do
      expect do
        FactoryGirl.create(:organization, :allow_sharing => false)
      end.not_to change { Delayed::Job.count }
    end
  end

  it "checks if the organization is active or not" do
    org = FactoryGirl.create(:organization, :status => Organization::Status::INACTIVE)
    org.status = Organization::Status::ACTIVE
    org.should be_active
  end

  context "status change" do
    it "allows an organization to be activated" do
      org = FactoryGirl.create(:organization, :status => Organization::Status::INACTIVE)
      org.activate.should be_true
      org.reload.status.should eq Organization::Status::ACTIVE
    end

    it "allows an organization to be deactivated" do
      org = FactoryGirl.create(:organization, :status => Organization::Status::ACTIVE)
      org.deactivate.should be_true
      org.reload.status.should eq Organization::Status::INACTIVE
    end
  end

  context "when validating default_locale" do
    it "uses i18n.default_locale if default_locale is not specified" do
      org = FactoryGirl.create(:organization)
      org.default_locale.should == I18n.default_locale.to_s
    end

    it "allows a standard rails locale" do
      org = FactoryGirl.build(:organization, :default_locale => 'fr')
      org.should be_valid
    end

    it "does not allow an invalid locale" do
      org = FactoryGirl.build(:organization, :default_locale => 'abcd')
      org.should_not be_valid
    end
  end

  it "returns a list of field agents for the organization" do
    org = FactoryGirl.create(:organization)
    user = FactoryGirl.create(:user)
    org.users << user
    org.field_agents.should include user
  end

  context "when creating an organization" do
    it "creates an Organization and the cso admin for it" do
      org_params = FactoryGirl.attributes_for(:organization, :name => "my_org")
      cso_admin_params = FactoryGirl.attributes_for(:cso_admin_user, :name => "cso_admin_user")
      organization = Organization.build(org_params, cso_admin_params)
      organization.save
      organization.reload.name.should == "my_org"
      organization.cso_admins.first.name.should == "cso_admin_user"
    end

    it "sets the allow_sharing field" do
      org_params = FactoryGirl.attributes_for(:organization, :allow_sharing => true)
      cso_admin_params = FactoryGirl.attributes_for(:cso_admin_user)
      organization = Organization.build(org_params, cso_admin_params)
      organization.save
      organization.reload.allow_sharing.should be_true
    end

    it "creates an active cso_admin" do
      org_params = FactoryGirl.attributes_for(:organization)
      cso_admin_params = FactoryGirl.attributes_for(:cso_admin_user)
      organization = Organization.build(org_params, cso_admin_params)
      organization.save
      organization.cso_admins.first.status.should == 'active'
    end
  end

  it "returns a list of active organizations" do
    org = FactoryGirl.create(:organization, :status => Organization::Status::ACTIVE)
    another_org = FactoryGirl.create(:organization, :status => Organization::Status::INACTIVE)
    Organization.active_organizations.should include org
    Organization.active_organizations.should_not include another_org
  end

  it "returns true if organizations exists for given user_ids" do
    organization = FactoryGirl.create(:organization)
    another_organization = FactoryGirl.create(:organization)
    Organization.valid_ids?([organization, another_organization]).should be_true
  end

  it "returns false if a organization doesn't exist for given user_ids" do
    organization = FactoryGirl.create(:organization)
    Organization.valid_ids?([organization, 3]).should be_false
  end

  it "returns all the organization listed in the yml file" do
    Organization.types.should =~ ['CSO', 'Financial Institution']
  end

  context "when soft deleting self and associated" do
    it "spins up a delayed job to initiate soft-delete" do
      organization = FactoryGirl.create(:organization)
      expect { organization.soft_delete_self_and_associated }.to change { Delayed::Job.where(:queue => "deregister_organization").count }.by(1)
    end

    it "soft-deletes the organization in 48 hours" do
      organization = FactoryGirl.create(:organization)
      organization.soft_delete_self_and_associated
      Timecop.travel(47.hours.from_now)
      expect { Delayed::Worker.new.work_off }.not_to change { organization.reload.deleted_at }
      Timecop.travel(1.hours.from_now)
      expect { Delayed::Worker.new.work_off }.to change { organization.reload.deleted_at }
    end

    it "soft-deletes the organization's users" do
      organization = FactoryGirl.create(:organization)
      user = FactoryGirl.create(:user, :organization => organization)
      organization.soft_delete_self_and_associated
      user.reload.should be_soft_deleted
    end

    it "spins up a delayed job which queues the email to be send out to admins" do
      organization = FactoryGirl.create(:organization)
      expect do
        organization.soft_delete_self_and_associated
      end.to change { Delayed::Job.where(:queue => "deregister_organization_notify_superadmins").count }.by(1)
    end

    it "sends an email" do
      organization = FactoryGirl.create(:organization, :users => [FactoryGirl.create(:cso_admin_user)])
      organization.soft_delete_self_and_associated
      expect { Delayed::Worker.new.work_off }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end

  it_behaves_like "a soft-deletable element"
end
