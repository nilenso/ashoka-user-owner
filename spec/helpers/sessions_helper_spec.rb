require 'spec_helper'

describe SessionsHelper do
  it "returns a url without the path" do
    application_url("http://google.com/abc/xyz").should == "http://google.com"
  end
end
