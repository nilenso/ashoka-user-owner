# encoding: UTF-8

require "spec_helper"

describe UserMailer do
  it "sends an approval mail to the user" do
    org = FactoryGirl.create(:organization)
    user = FactoryGirl.create(:user, :email => "bar@foo.com", :organization => org)
    lambda { UserMailer.approval_mail(user, 'en') }.should_not raise_error
    lambda { UserMailer.approval_mail(user, 'en').deliver }.should_not raise_error
    lambda { UserMailer.approval_mail(user, 'en').deliver }.should change(ActionMailer::Base.deliveries,:size).by(1)
  end

  it "sends a rejection mail to the user" do
    org = FactoryGirl.create(:organization)
    user = FactoryGirl.create(:user, :email => "baz@foo.com", :organization => org)
    lambda { UserMailer.rejection_mail(user, 'en') }.should_not raise_error
    lambda { UserMailer.rejection_mail(user, 'en').deliver }.should_not raise_error
    lambda { UserMailer.rejection_mail(user, 'en').deliver }.should change(ActionMailer::Base.deliveries,:size).by(1)
  end

  it "should be delivered to the user's email" do
    org = FactoryGirl.create(:organization)
    user = FactoryGirl.create(:user, :email => "baz@foo.com", :organization => org)
    email = UserMailer.approval_mail(user, 'en')
    email.should deliver_to('baz@foo.com')
  end

  it "should have the user's name in the body" do
    org = FactoryGirl.create(:organization)
    user = FactoryGirl.create(:user, :email => "baz@foo.com", :organization => org)
    email = UserMailer.approval_mail(user, 'en')
    email.should have_body_text(user.name)
    email = UserMailer.rejection_mail(user, 'en')
    email.should have_body_text(user.name)
  end

  it "should have the organization's name in the body" do
    org = FactoryGirl.create(:organization)
    user = FactoryGirl.create(:user, :email => "baz@foo.com", :organization => org)
    email = UserMailer.approval_mail(user, 'en')
    email.should have_body_text(org.name)
    email = UserMailer.rejection_mail(user, 'en')
    email.should have_body_text(org.name)
  end

  it "should deliver from an email at the same domain" do
    org = FactoryGirl.create(:organization)
    user = FactoryGirl.create(:user, :email => "baz@foo.com", :organization => org)
    email = UserMailer.approval_mail(user, 'en')
    email.should deliver_from("\"User Owner Robot\" <friendly_robot@user-owner-staging.herokuapp.com>")
  end

  it "should include the rejection message in the body" do
    org = FactoryGirl.create(:organization)
    user = FactoryGirl.create(:user, :email => "baz@foo.com", :organization => org)
    email = UserMailer.rejection_mail(user, 'en', "someuniquemessage")
    email.should have_body_text("someuniquemessage")
  end

  context "when sending an email in the organization's default locale" do
    it "sends an approval mail in the correct locale" do
      org = FactoryGirl.create(:organization, :default_locale => 'fr')
      user = FactoryGirl.create(:user, :email => "baz@foo.com", :organization => org)
      email = UserMailer.approval_mail(user, 'fr')
      email.should have_body_text("Bienvenue au service")
    end

    it "sends a rejection mail in the correct locale" do
      org = FactoryGirl.create(:organization, :default_locale => 'fr')
      user = FactoryGirl.create(:user, :email => "baz@foo.com", :organization => org)
      email = UserMailer.rejection_mail(user, 'fr', "REJECTED!")
      email.should have_body_text("Désolé")
    end
  end

  context "password reset" do
    it "sends a password reset mail to user" do
    org = FactoryGirl.create(:organization)
    user = FactoryGirl.create(:user, :email => "bar@foo.com", :organization => org)
    user.generate_password_reset_token
    lambda { UserMailer.password_reset_mail(user) }.should_not raise_error
    lambda { UserMailer.password_reset_mail(user).deliver }.should_not raise_error
    lambda { UserMailer.password_reset_mail(user).deliver }.should change(ActionMailer::Base.deliveries,:size).by(1)
    end
  end
end
