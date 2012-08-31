# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    sequence(:name){ |n|  "xyz_#{n}" }
    sequence(:email){ |n| "xyz#{n}@aa.com"}
    password "foo"
    password_confirmation "foo"
    before(:create) { |user| user.role = 'user' }

    factory :admin_user do
      before(:create) { |user| user.role = 'admin' }
    end

    factory :cso_admin_user do
      before(:create) { |user| user.role = 'cso_admin' }
    end
  end
end
