require 'spec_helper'

shared_examples "a soft-deletable element" do
  context "when performing the soft-delete" do
    it "sets the `deleted_at` for the element" do
      date = Date.today
      Timecop.freeze(date) { element.soft_delete }
      element.deleted_at.should == date
    end
  end
end
