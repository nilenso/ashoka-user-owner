require "spec_helper"

describe UserMailer do
  include EmailSpec::Helpers
  include EmailSpec::Matchers

  it "sends an approval mail to the user" do
    org = FactoryGirl.create(:organization)
    user = FactoryGirl.create(:user, :email => "bar@foo.com", :organization => org)
    lambda { UserMailer.approval_mail(user) }.should_not raise_error
    lambda { UserMailer.approval_mail(user).deliver }.should_not raise_error
    lambda { UserMailer.approval_mail(user).deliver }.should change(ActionMailer::Base.deliveries,:size).by(1)
  end

  it "sends a rejection mail to the user" do
    org = FactoryGirl.create(:organization)
    user = FactoryGirl.create(:user, :email => "baz@foo.com", :organization => org)
    lambda { UserMailer.rejection_mail(user) }.should_not raise_error
    lambda { UserMailer.rejection_mail(user).deliver }.should_not raise_error
    lambda { UserMailer.rejection_mail(user).deliver }.should change(ActionMailer::Base.deliveries,:size).by(1)
  end

  it "should be delivered to the user's email" do
    org = FactoryGirl.create(:organization)
    user = FactoryGirl.create(:user, :email => "baz@foo.com", :organization => org)
    email = UserMailer.approval_mail(user)
    email.should deliver_to('baz@foo.com')
  end

  it "should have the user's name in the body" do
    org = FactoryGirl.create(:organization)
    user = FactoryGirl.create(:user, :email => "baz@foo.com", :organization => org)
    email = UserMailer.approval_mail(user)
    email.should have_body_text(user.name)
    email = UserMailer.rejection_mail(user)
    email.should have_body_text(user.name)
  end


  it "should have the organization's name in the body" do
    org = FactoryGirl.create(:organization)
    user = FactoryGirl.create(:user, :email => "baz@foo.com", :organization => org)
    email = UserMailer.approval_mail(user)
    email.should have_body_text(org.name)
    email = UserMailer.rejection_mail(user)
    email.should have_body_text(org.name)
  end

  it "should deliver from an email at the same domain" do
    org = FactoryGirl.create(:organization)
    user = FactoryGirl.create(:user, :email => "baz@foo.com", :organization => org)
    email = UserMailer.approval_mail(user)
    email.should deliver_from("\"User Owner Robot\" <friendly_robot@user-owner-staging.herokuapp.com>")
  end
end
