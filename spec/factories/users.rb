# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    sequence(:name){ |n|  "xyz_#{n}" }
    sequence(:email){ |n| "xyz#{n}@aa.com"}
    password "foo"
    password_confirmation "foo"
    before(:create) { |user| user.role = 'field_agent' }

    User::ROLES.each do |role|
      x = ("#{role}_user").to_sym
      factory x do
        before(:create) { |user| user.role = role }
      end
    end
  end
end
