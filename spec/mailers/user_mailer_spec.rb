require "spec_helper"

describe UserMailer do
  it "sends an approval mail to the user" do
    org = FactoryGirl.create(:organization)
    user = FactoryGirl.create(:user, :email => "bar@foo.com", :organization => org)
    lambda { UserMailer.approval_mail(user) }.should_not raise_error
    lambda { UserMailer.approval_mail(user).deliver }.should_not raise_error
    lambda { UserMailer.approval_mail(user).deliver }.should change(ActionMailer::Base.deliveries,:size).by(1)
  end
end
