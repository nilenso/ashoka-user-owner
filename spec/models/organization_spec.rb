require 'spec_helper'

describe Organization do
  subject { FactoryGirl.create(:organization) }
  it { should have_many(:users) }
  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }
  it { should respond_to(:status) }
  it { should respond_to(:default_locale) }

  context "Logic" do
    it "checks if the organization is approved or not" do
      org = FactoryGirl.create(:organization)
      org.should_not be_approved
      org.status = Organization::Status::APPROVED
      org.should be_approved
    end

    it "checks if the organization is rejected or not" do
      org = FactoryGirl.create(:organization)
      org.should_not be_rejected
      org.status = Organization::Status::REJECTED
      org.should be_rejected
    end
  end

  context "status change" do
    it "allows a new organization to be approved" do
      org = FactoryGirl.create(:organization, :status => Organization::Status::PENDING)
      org.approve!.should be_true
      org.reload.status.should eq Organization::Status::APPROVED
    end

    it "does not allow to approve an already rejected organization" do
      rejected_org = FactoryGirl.create(:organization, :status => Organization::Status::REJECTED)
      lambda{
        rejected_org.approve!
      }.should raise_error(StandardError, "A rejected organization cannot be approved")
      rejected_org.reload.status.should eq Organization::Status::REJECTED
    end

    it "does not allow to approve an already rejected organization" do
      rejected_org = FactoryGirl.create(:organization, :status => Organization::Status::APPROVED)
      lambda{
        rejected_org.reject!
      }.should raise_error(StandardError, "A approved organization cannot be rejected")
      rejected_org.reload.status.should eq Organization::Status::APPROVED
    end

    it "allows to reject a new organization" do
      org = FactoryGirl.create(:organization, :status => Organization::Status::PENDING)
      org.reject!.should be_true
      org.reload.status.should eq Organization::Status::REJECTED
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

  it "returns the cso admin of the Organization" do
    org = FactoryGirl.create(:organization)
    cso_ad = FactoryGirl.create(:cso_admin_user, :role => 'cso_admin')
    org.users << cso_ad
    org.cso_admin.should == cso_ad
  end

  context "when creating an organization" do
    it "creates an Organization and the cso admin for it" do\
      org_params = {:name => "my_org"}
      cso_admin_params = {:name => "cso_admin_user", :email => "xyz@abc.com", :password => "abc",
                     :password_confirmation => 'abc'}
      organization = Organization.build(org_params[:name], cso_admin_params)
      organization.save
      organization.reload.name.should == "my_org"
      organization.cso_admin.name.should == "cso_admin_user"
    end
  end

  it "returns a list of approved organizations" do
    org = FactoryGirl.create(:organization, :status => Organization::Status::APPROVED)
    another_org = FactoryGirl.create(:organization, :status => Organization::Status::PENDING)
    Organization.approved_organizations.should include org
    Organization.approved_organizations.should_not include another_org
  end
end
