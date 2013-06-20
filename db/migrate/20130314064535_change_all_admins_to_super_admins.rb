class ChangeAllAdminsToSuperAdmins < ActiveRecord::Migration
  class TempUser < ActiveRecord::Base
    self.table_name = :users
  end

  def up
    users = TempUser.where(:role => "admin")
    users.each do |user|
      user.role = 'super_admin'
      user.save
    end
  end

  def down
    users = TempUser.where(:role => "super_admin")
    users.each do |user|
      user.role = 'admin'
      user.save
    end
  end
end
