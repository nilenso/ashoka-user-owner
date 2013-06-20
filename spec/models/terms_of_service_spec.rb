require 'spec_helper'

describe TermsOfService do
  it { should validate_presence_of(:document) }

  context "scopes" do
    it "gets the latest terms of service" do
      new_terms_of_service = Timecop.freeze(2.days.ago) { FactoryGirl.create(:terms_of_service) }
      old_terms_of_service = Timecop.freeze(10.days.ago) { FactoryGirl.create(:terms_of_service) }
      TermsOfService.latest.should == new_terms_of_service
    end
  end
end
