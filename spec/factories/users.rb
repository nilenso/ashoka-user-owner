# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    name "xyz"
    sequence(:email){ |n| "xyz#{n}@aa.com"}
    password "foo"
    password_confirmation "foo"
  end
end
