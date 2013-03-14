class ChangeAllAdminsToSuperAdmins < ActiveRecord::Migration
  def up
    users = User.where(:role => "admin")
    users.each do |user|
      user.role = 'super_admin'
      user.save
    end
  end

  def down
    users = User.where(:role => "super_admin")
    users.each do |user|
      user.role = 'admin'
      user.save
    end
  end
end
