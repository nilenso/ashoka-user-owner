class UserMailer < ActionMailer::Base
  default from: "\"User Owner Robot\" <friendly_robot@user-owner-staging.herokuapp.com>"

  def approval_mail(user, locale)
    @user = user
    I18n.with_locale(locale.to_sym) do
      mail(:to => user.email, :subject => "Welcome to user owner")
    end
  end

  def rejection_mail(user, locale, message=nil)
    @user = user
    @message = message
    I18n.with_locale(locale.to_sym) do
      mail(:to => user.email, :subject => "Your organization has not been approved")
    end
  end

  def password_reset_mail(user)
    @user = user
    mail(:to => user.email, :subject => t("user_mailer.password_reset_mail.subject", 
                                        :organization_name => user.organization.name))
  end
end
