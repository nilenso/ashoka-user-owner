# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    sequence(:name){ |n|  "xyz_#{n}" }
    sequence(:email){ |n| "xyz#{n}@aa.com"}
    password "foo"
    password_confirmation "foo"
    role 'field_agent'

    trait :active do
      status User::Status::ACTIVE
    end

    factory :viewer_user do
      role 'viewer'
    end

    factory :field_agent_user do
      role 'field_agent'
    end

    factory :supervisor_user do
      role 'supervisor'
    end

    factory :designer_user do
      role 'designer'
    end

    factory :manager_user do
      role 'manager'
    end

    factory :cso_admin_user do
      role 'cso_admin'
    end

    factory :super_admin_user do
      role 'super_admin'
    end
  end
end
