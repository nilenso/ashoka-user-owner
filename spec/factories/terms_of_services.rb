include ActionDispatch::TestProcess

FactoryGirl.define do
  factory :terms_of_service do
    document { fixture_file_upload("spec/fixtures/documents/placeholder.pdf") }
  end
end
