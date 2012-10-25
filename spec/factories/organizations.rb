# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :organization do
    sequence(:name){ |n|  "xyz_#{n}" }
    status { Organization::Status::ACTIVE }
  end
end
