# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    sequence(:name){ |n|  "xyz_#{n}" }
    sequence(:email){ |n| "xyz#{n}@aa.com"}
    password "foo"
    password_confirmation "foo"
  end
end
