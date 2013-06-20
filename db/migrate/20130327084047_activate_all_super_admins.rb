class ActivateAllSuperAdmins < ActiveRecord::Migration
  class TempUser < ActiveRecord::Base
    self.table_name = :users
  end

  def up
    TempUser.where(:role => 'super_admin', :status => 'pending').each do |user|
      user.update_column(:status, 'active')
    end
  end

  def down
  end
end
