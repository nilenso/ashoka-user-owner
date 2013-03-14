require "highline/import"

namespace :db do
  desc 'Add an admin user'
  task :super_admin => :environment do
    puts('Enter the credentials for the super_admin user.')
    username = get('Username: ')
    email =  get("Email: ")
    password = ask("Password: ") { |q| q.echo = false }
    password_confirm = ask("Confirm password: ") { |q| q.echo = false }

    user = User.new(:name => username, :password => password, :password_confirmation => password_confirm, :email => email)
    user.role = 'super_admin'
    
    if user.save
      puts "Admin user created."
    else
      puts "Couldn't create super_admin user. There were errors."
      user.errors.messages.each do |field, messages|
        messages.each { |message| puts "  * #{field.capitalize} #{message}" }
      end
      exit 1
    end
  end

  def get message
    print message
    STDIN.gets.chomp
  end
end
