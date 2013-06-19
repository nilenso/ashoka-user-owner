require 'spec_helper'

shared_examples "a soft-deletable element" do
  let!(:element) { FactoryGirl.create(described_class) }
  let!(:deleted_element) { FactoryGirl.create(described_class, :deleted_at => 5.days.ago) }

  context "when performing the soft-delete" do
    it "sets the `deleted_at` for the element" do
      date = Date.today
      Timecop.freeze(date) { element.soft_delete }
      element.deleted_at.should == date
    end
  end

  context "scopes" do
    it "finds all the elements that are soft-deleted" do
      described_class.unscoped.deleted.should == [deleted_element]
    end

    it "finds all the elements that are not soft-deleted" do
      described_class.not_deleted.should == [element]
    end

    it "excludes soft-deleted elements by default" do
      described_class.all.should == [element]
    end
  end

  it "checks if an element is deleted" do
    element.should_not be_soft_deleted
    deleted_element.should be_soft_deleted
  end
end
