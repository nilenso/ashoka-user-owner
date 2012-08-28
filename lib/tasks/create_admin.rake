namespace :db do
	desc 'Add an admin user'
	task :admin => :environment do
		user = User.new(:name => "admin", :password => "admin", :password_confirmation => "admin", :email => "admin@change.com")
		user.role = 'admin'
		user.save
	end
end