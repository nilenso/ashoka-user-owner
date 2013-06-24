include ActionDispatch::TestProcess

FactoryGirl.define do
  trait :document do
    document { fixture_file_upload("spec/fixtures/documents/placeholder.pdf") }
  end

  factory :terms_of_service do
    document
  end

  factory :privacy_policy do
    document
  end
end
