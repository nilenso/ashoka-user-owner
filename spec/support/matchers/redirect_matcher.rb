RSpec::Matchers.define :redirect_to_path do |expected|
  match do |response|
    full_path = response.header["Location"]
    path = full_path.split("?").first
    expected == path
  end

  failure_message_for_should do |actual|
    "Expected response to redirect to #{expected} instead of #{actual.header["Location"]}"
  end
end
