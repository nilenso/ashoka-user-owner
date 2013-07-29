require 'spec_helper'

shared_examples "a document" do
  context "scopes" do
    it "gets the latest document" do
      new_document = Timecop.freeze(2.days.ago) { FactoryGirl.create(described_class) }
      old_document = Timecop.freeze(10.days.ago) { FactoryGirl.create(described_class) }
      described_class.latest.should == new_document
    end
  end
end
