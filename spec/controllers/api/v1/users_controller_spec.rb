require 'spec_helper'

describe Api::V1::UsersController do
  it "returns all the info for a User in JSON excluding password" do
    user = FactoryGirl.create(:user)
    p response
    response.body.should == user.as_json(except: :password_digest)
  end
end
