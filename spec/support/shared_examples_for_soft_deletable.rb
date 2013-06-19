require 'spec_helper'

shared_examples "a soft-deletable element" do
  context "when performing the soft-delete" do
    it "sets the `deleted_at` for the element" do
      date = Date.today
      Timecop.freeze(date) { element.soft_delete }
      element.deleted_at.should == date
    end
  end

  context "scopes" do
    let!(:element) { FactoryGirl.create(described_class) }
    let!(:deleted_element) { FactoryGirl.create(described_class, :deleted_at => 5.days.ago) }

    it "finds all the elements that are not soft-deleted" do
      described_class.not_deleted.should == [element]
    end

    it "excludes soft-deleted elements by default" do
      described_class.all.should == [element]
    end
  end
end
