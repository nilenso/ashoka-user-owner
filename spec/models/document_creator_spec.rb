require "spec_helper"

describe DocumentCreator do
  context "terms of service" do
    it "creates a TermsOfService if the params for it are passed in" do
      expect do
        DocumentCreator.new(:terms_of_service => FactoryGirl.attributes_for(:terms_of_service))
      end.to change { TermsOfService.count }.by 1
    end

    it "doesn't create a TermsOfService if the params for it are not passed in" do
      expect do
        DocumentCreator.new(:terms_of_service => nil)
      end.not_to change { TermsOfService.count }
    end
  end

  context "privacy policy" do
    it "creates a PrivacyPolicy if the params for it are passed in" do
      expect do
        DocumentCreator.new(:privacy_policy => FactoryGirl.attributes_for(:privacy_policy))
      end.to change { PrivacyPolicy.count }.by 1
    end

    it "doesn't create a PrivacyPolicy if the params for it are not passed in" do
      expect do
        DocumentCreator.new(:privacy_policy => nil)
      end.not_to change { PrivacyPolicy.count }
    end
  end

  context "errors" do
    it "doesn't create a PrivacyPolicy if invalid params for terms of service are passed in" do
      expect do
        DocumentCreator.new(:privacy_policy => FactoryGirl.attributes_for(:privacy_policy),
                            :terms_of_service => FactoryGirl.attributes_for(:terms_of_service, :document => nil))
      end.not_to change { PrivacyPolicy.count }
    end

    it "doesn't create a TermsOfService if invalid params for privacy policy are passed in" do
      expect do
        DocumentCreator.new(:privacy_policy => FactoryGirl.attributes_for(:privacy_policy, :document => nil),
                            :terms_of_service => FactoryGirl.attributes_for(:terms_of_service))
      end.not_to change { TermsOfService.count }
    end

    it "returns the ActiveModel::Errors objects for each of the documents" do
      documents = DocumentCreator.new(:privacy_policy => FactoryGirl.attributes_for(:privacy_policy, :document => nil))
      documents.errors[0].full_messages.should include "Document can't be blank"
    end
  end
end
