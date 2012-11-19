require "highline/import"

namespace :db do
  desc 'Add a cso_admin and a field_agent'
  task :users => :environment do
    organization = Organization.new(:name => "My Organization")

    cso_admin = User.new(:name => "cso_admin",
                         :password => "cso_admin",
                         :password_confirmation => "cso_admin",
                         :email => "cso_admin@admin.com",
                         )
    cso_admin.role = "cso_admin"
    cso_admin.organization = organization

    field_agent = User.new(:name => "field_agent",
                         :password => "field_agent",
                         :password_confirmation => "field_agent",
                         :email => "field_agent@admin.com",
                        )
    field_agent.role = "field_agent"
    field_agent.organization = organization

    if organization.save && cso_admin.save && field_agent.save
      puts "1 Organization created."
      puts "1 cso_admin created."
      puts "1 field_agent created."
    else
      puts "Couldn't create the users. There were errors."
      puts organization.errors.messages
      puts cso_admin.errors.messages
      puts field_agent.errors.messages
      exit 1
    end
  end
end
