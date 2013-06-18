require 'spec_helper'

describe Organization do
  subject { FactoryGirl.create(:organization) }
  it { should have_many(:users) }
  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }
  it { should respond_to(:status) }
  it { should respond_to(:default_locale) }

  context "Logic" do
    it "checks if the organization is active or not" do
      org = FactoryGirl.create(:organization, :status => Organization::Status::INACTIVE)
      org.status = Organization::Status::ACTIVE
      org.should be_active
    end
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

  it "returns the cso admin of the Organization" do
    org = FactoryGirl.create(:organization)
    cso_ad = FactoryGirl.create(:cso_admin_user, :role => 'cso_admin')
    org.users << cso_ad
    org.cso_admin.should == cso_ad
  end

  context "when creating an organization" do
    it "creates an Organization and the cso admin for it" do\
      org_params = {:name => "my_org", :org_type => "CSO"}
      cso_admin_params = {:name => "cso_admin_user", :email => "xyz@abc.com", :password => "abc",
                     :password_confirmation => 'abc'}
      organization = Organization.build(org_params, cso_admin_params)
      organization.save
      organization.reload.name.should == "my_org"
      organization.cso_admin.name.should == "cso_admin_user"
    end

    it "creates an active cso_admin" do
      org_params = {:name => "my_org", :org_type => "CSO"}
      cso_admin_params = {:name => "cso_admin_user", :email => "xyz@abc.com", :password => "abc",
                     :password_confirmation => 'abc'}
      organization = Organization.build(org_params, cso_admin_params)
      organization.save
      organization.cso_admin.status.should == 'active'
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

  it_behaves_like "a soft-deletable element" do
    let(:element) { FactoryGirl.create(:organization) }
  end
end
