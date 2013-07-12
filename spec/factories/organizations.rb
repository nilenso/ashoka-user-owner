FactoryGirl.define do
  factory :organization do
    sequence(:name){ |n|  "xyz_#{n}" }
    org_type 'CSO'

    trait :with_logo do
      logo { fixture_file_upload(Rails.root.to_s + '/spec/fixtures/logos/logo.png', 'image/png') }
    end
  end
end
