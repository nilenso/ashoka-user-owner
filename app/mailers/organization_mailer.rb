class OrganizationMailer < ActionMailer::Base
  default from: "no-reply@users.thesurveys.org"

  def notify_super_admins_of_organization_that_allows_sharing(organization_name)
    @organization_name = organization_name
    mail(:to => User.super_admins.pluck(:email), :subject => I18n.t("organization_mailer.notify_super_admins_of_organization_that_allows_sharing.subject", :organization_name => organization_name))
  end
end
