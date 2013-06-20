class ActivateAllCsoAdmins < ActiveRecord::Migration
  class TempUser < ActiveRecord::Base
    self.table_name = :users
  end

  def up
    TempUser.where(:role => 'cso_admin', :status => 'pending').each do |user|
      user.update_column(:status, 'active')
    end
  end

  def down
  end
end
