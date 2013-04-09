require "highline/import"

namespace :db do
  desc 'Add a user for each role'
  task :users => :environment do
    organization = Organization.new(:name => "My Organization")
    organization.org_type = "CSO"
    organization.save

    User::ROLES.each do |role|
      user = User.new(:name => "#{role}_user",
                      :password => "foo",
                      :password_confirmation => "foo",
                      :email => "#{role}@foo.com",
                      )
      user.role = role
      user.organization = organization

      if user.save
        puts "Successfully created a #{role}"
      else
        puts "There were errors creating a #{role}"
      end
    end
  end
end
