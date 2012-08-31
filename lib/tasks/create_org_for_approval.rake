namespace :db do
  desc 'Add an admin user'
  task :create_orgs_for_approval => :environment do
    10.times do
      random = (0...5).map { ('a'..'z').to_a[rand(26)] }.join
      Organization.create(name: 'asd',
        users_attributes: {'0' => {name: 'asd', email:"abc#{random}@abc.com", password: '123', password_confirmation: '123'}})
    end
  end
end
