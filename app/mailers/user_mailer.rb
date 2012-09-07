class UserMailer < ActionMailer::Base
  default from: "\"User Owner Robot\" <friendly_robot@user-owner-staging.herokuapp.com>"

  def approval_mail(user, locale)
    @user = user
    mail(:to => user.email, :subject => "Welcome to user owner")
  end

  def rejection_mail(user, locale, message=nil)
    @user = user
    @message = message
    mail(:to => user.email, :subject => "Your organization has not been approved")
  end

  def password_reset_mail(user)
    @user = user
    mail(:to => user.email, :subject => "Password Reset")
  end
end
