class UserMailer < ActionMailer::Base
  default from: "\"User Owner Robot\" <friendly_robot@user-owner-staging.herokuapp.com>"

  def activation_mail(user, locale)
    @user = user
    I18n.with_locale(locale.to_sym) do
      mail(:to => user.email, :subject => "Welcome to user owner. Your organization has been activated")
    end
  end

  def deactivation_mail(user, locale, message=nil)
    @user = user
    @message = message
    I18n.with_locale(locale.to_sym) do
      mail(:to => user.email, :subject =>  "Your organization has been deactivated.")
    end
  end

  def password_reset_mail(user)
    @user = user
    if user.active?
      subject = t("user_mailer.password_reset_mail.reset_password_subject")
    else
      subject = t("user_mailer.password_reset_mail.subject", :organization_name => user.organization.name)
    end
    mail(:to => user.email, :subject => subject)
  end
end
