require "cancan/matchers"

describe Ability do
  subject { ability }
  let(:ability){ Ability.new(user) }

  context "when not logged in" do
    let(:user) { nil }
    it { should be_able_to :create, Organization }
  end

  context "for Users" do
    let(:organization) { FactoryGirl.create(:organization)}

    context "when is an super_admin" do
      let(:user) { FactoryGirl.create :super_admin_user  }

      it { should be_able_to :names_for_ids, User }
      it { should be_able_to :manage, Organization.new }
      it { should_not be_able_to :manage, User.new }
    end

    context "when is a cso_admin" do
      let(:user) { FactoryGirl.create :cso_admin_user, :organization => organization  }

      it { should_not be_able_to :manage, Organization.new }
      it { should be_able_to :read, organization }

      it { should be_able_to :names_for_ids, User }

      it { should be_able_to :manage, FactoryGirl.create(:user, :organization_id => organization.id) }
      it { should_not be_able_to :manage, FactoryGirl.create(:user, :organization_id => 2342342) }

    end

    context "when is a user" do
      let(:user) { FactoryGirl.create :user, :organization => organization  }

      it { should be_able_to :read, organization }
      it { should_not be_able_to :manage, Organization.new }

      it { should be_able_to :names_for_ids, User }

      it { should be_able_to :read, user }
      it { should_not be_able_to :manage, User.new }
    end

    %w(viewer field_agent supervisor designer manager).each do |role|
      context "when is a #{role}" do
        let(:user) { FactoryGirl.create("#{role}_user".to_sym, :organization_id => 5)}
        let(:user_in_other_org) { FactoryGirl.create("#{role}_user".to_sym, :organization_id => 6)}

        it { should_not be_able_to :manage, User }
        it { should_not be_able_to :manage, Organization }

        it { should be_able_to :read, user }
        it { should_not be_able_to :read, user_in_other_org }
      end
    end
  end
end
