namespace :db do
  desc 'Add an admin user'
  task :create_orgs_for_approval => :environment do
    10.times do |i|
      Organization.create(name: 'asd',
        users_attributes: {'0' => {name: 'asd', email:"abc#{i}@abc.com", password: '123', password_confirmation: '123'}})
    end
  end
end
