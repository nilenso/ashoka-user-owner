require "spec_helper"

describe OrganizationMailer do
  context "when a new organization is created" do
    it "sends an email" do
      super_admins = FactoryGirl.create_list(:super_admin_user, 5)
      expect{ OrganizationMailer.notify_super_admins_of_organization_that_allows_sharing("Foo Org").deliver }.to change {
        ActionMailer::Base.deliveries.count
      }.by(1)
    end

    it "sends out email to super admins" do
      super_admins = FactoryGirl.create_list(:super_admin_user, 5)
      cso_admin = FactoryGirl.create(:cso_admin_user)
      email = OrganizationMailer.notify_super_admins_of_organization_that_allows_sharing("Foo Org")
      email.should deliver_to(*super_admins.map(&:email))
    end

    it "includes the organization name in the subject" do
      email = OrganizationMailer.notify_super_admins_of_organization_that_allows_sharing("Foo Org")
      email.should have_subject /Foo Org/
    end

    it "includes the organization name in the email body" do
      email = OrganizationMailer.notify_super_admins_of_organization_that_allows_sharing("Foo Org")
      email.should have_body_text /Foo Org/
    end
  end

  context "when terms of service is changed" do
    let!(:cso_admins) { FactoryGirl.create_list(:cso_admin_user, 5) }

    it "sends an email" do
      expect { OrganizationMailer.notify_cso_admins_of_change_in_terms_of_service.deliver }.to change {
        ActionMailer::Base.deliveries.count
      }.by(1)
    end

    it "addresses the emails to the CSO admins (in BCC)" do
      email = OrganizationMailer.notify_cso_admins_of_change_in_terms_of_service
      email.should bcc_to(*cso_admins.map(&:email))
    end
  end

  context "when privacy policy is changed" do
    let!(:cso_admins) { FactoryGirl.create_list(:cso_admin_user, 5) }

    it "sends an email" do
      expect { OrganizationMailer.notify_cso_admins_of_change_in_privacy_policy.deliver }.to change {
        ActionMailer::Base.deliveries.count
      }.by(1)
    end

    it "addresses the emails to the CSO admins (in BCC)" do
      email = OrganizationMailer.notify_cso_admins_of_change_in_privacy_policy
      email.should bcc_to(*cso_admins.map(&:email))
    end
  end
end
