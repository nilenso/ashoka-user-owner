require 'spec_helper'

describe TermsOfService do
  it { should validate_presence_of(:document) }
end
