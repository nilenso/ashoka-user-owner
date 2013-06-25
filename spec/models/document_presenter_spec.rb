require "spec_helper"

describe DocumentPresenter do
  context "terms of service" do
    it "creates a TermsOfService if the params for it are passed in" do
      documents = DocumentPresenter.new(:terms_of_service => FactoryGirl.attributes_for(:terms_of_service))
      expect do
        documents.save
      end.to change { TermsOfService.count }.by 1
    end

    it "doesn't create a TermsOfService if the params for it are not passed in" do
      expect do
        DocumentPresenter.new(:terms_of_service => nil).save
      end.not_to change { TermsOfService.count }
    end
  end

  context "privacy policy" do
    it "creates a PrivacyPolicy if the params for it are passed in" do
      expect do
        DocumentPresenter.new(:privacy_policy => FactoryGirl.attributes_for(:privacy_policy)).save
      end.to change { PrivacyPolicy.count }.by 1
    end

    it "doesn't create a PrivacyPolicy if the params for it are not passed in" do
      expect do
        DocumentPresenter.new(:privacy_policy => nil).save
      end.not_to change { PrivacyPolicy.count }
    end
  end

  context "errors" do
    it "doesn't create a PrivacyPolicy if invalid params for terms of service are passed in" do
      expect do
        DocumentPresenter.new(:privacy_policy => FactoryGirl.attributes_for(:privacy_policy),
                            :terms_of_service => FactoryGirl.attributes_for(:terms_of_service, :document => nil)).save
      end.not_to change { PrivacyPolicy.count }
    end

    it "doesn't create a TermsOfService if invalid params for privacy policy are passed in" do
      expect do
        DocumentPresenter.new(:privacy_policy => FactoryGirl.attributes_for(:privacy_policy, :document => nil),
                            :terms_of_service => FactoryGirl.attributes_for(:terms_of_service))
      end.not_to change { TermsOfService.count }
    end

    it "returns an ActiveModel::Errors object containing validation errors for the documents" do
      documents = DocumentPresenter.new(:privacy_policy => FactoryGirl.attributes_for(:privacy_policy, :document => nil))
      documents.save
      documents.errors.full_messages.should include "Privacy policy Document can't be blank"
    end
  end

  context "saving" do
    it "returns true if save passes" do
      documents = DocumentPresenter.new(:terms_of_service => FactoryGirl.attributes_for(:terms_of_service))
      documents.save.should be_true
    end

    it "returns a falsy value if save fails" do
      documents = DocumentPresenter.new(:terms_of_service => FactoryGirl.attributes_for(:terms_of_service, :document => nil))
      documents.save.should be_false
    end
  end
end
