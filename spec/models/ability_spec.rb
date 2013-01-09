require "cancan/matchers"

describe "Abilities" do
  subject { ability }
  let(:ability){ Ability.new(user) }

  context "when not logged in" do
    let(:user) { nil }
    it { should be_able_to :create, Organization }
  end

  context "for Users" do


    context "when is an admin" do
      let(:user) { FactoryGirl.create :admin_user  }

      it { should be_able_to :names_for_ids, User }
      it { should be_able_to :manage, Organization.new }
      it { should_not be_able_to :manage, User.new }
    end

    context "when is a cso_admin" do
      let(:organization) { FactoryGirl.create(:organization)}
      let(:user) { FactoryGirl.create :cso_admin_user, :organization => organization  }

      it { should_not be_able_to :manage, Organization.new }
      it { should be_able_to :read, organization }

      it { should be_able_to :names_for_ids, User }

      it { should be_able_to :manage, FactoryGirl.create(:user, :organization_id => organization.id) }
      it { should_not be_able_to :manage, FactoryGirl.create(:user, :organization_id => 2342342) }

    end

    context "when is a user" do
      let(:organization) { FactoryGirl.create(:organization)}
      let(:user) { FactoryGirl.create :user, :organization => organization  }

      it { should be_able_to :read, organization }
      it { should_not be_able_to :manage, Organization.new }

      it { should be_able_to :names_for_ids, User }

      it { should be_able_to :read, user }
      it { should_not be_able_to :read, User.new }
    end
  end
end
