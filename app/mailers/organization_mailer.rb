class OrganizationMailer < ActionMailer::Base
  default from: "no-reply@users.thesurveys.org"

  def notify_super_admins_of_organization_that_allows_sharing(organization_name)
    @organization_name = organization_name
    mail(:to => User.super_admins.pluck(:email), :subject => I18n.t("organization_mailer.notify_super_admins_of_organization_that_allows_sharing.subject", :organization_name => organization_name))
  end

  def notify_cso_admins_of_change_in_terms_of_service
    mail(:bcc =>  User.cso_admins.pluck(:email), :subject => I18n.t("organization_mailer.notify_cso_admins_of_change_in_terms_of_service.subject"))
  end

  def notify_cso_admins_of_change_in_privacy_policy
    mail(:bcc =>  User.cso_admins.pluck(:email), :subject => I18n.t("organization_mailer.notify_cso_admins_of_change_in_privacy_policy.subject"))
  end

  def notify_deregister_organization_for(recipients, organization_name)
    @organization_name = organization_name
    mail(:bcc => recipients, :subject => I18n.t("organization_mailer.notify_deregister_organization_for.subject", :organization_name => organization_name))
  end
end
