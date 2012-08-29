class UserMailer < ActionMailer::Base
  default from: "admin@user_owner.app"

  def approval_mail(user)
    @user = user
    mail(:to => user.email, :from => 'srihari@c42.in', :subject => "Welcome to user owner")
  end
end
