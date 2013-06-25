require "spec_helper"

describe OrganizationMailer do
  context "when a new organization is created" do
    it "sends an email" do
      expect{ OrganizationMailer.notify_super_admins_of_organization_that_allows_sharing("Foo Org").deliver }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it "sends out email to super admins" do
      super_admins = FactoryGirl.create_list(:super_admin_user, 5)
      cso_admin = FactoryGirl.create(:cso_admin_user)
      email = OrganizationMailer.notify_super_admins_of_organization_that_allows_sharing("Foo Org").deliver
      email.should deliver_to(*super_admins.map(&:email))
    end

    it "includes the organization name in the subject" do
      email = OrganizationMailer.notify_super_admins_of_organization_that_allows_sharing("Foo Org").deliver
      email.should have_subject /Foo Org/
    end

    it "includes the organization name in the email body" do
      email = OrganizationMailer.notify_super_admins_of_organization_that_allows_sharing("Foo Org").deliver
      email.should have_body_text /Foo Org/
    end
  end
end
