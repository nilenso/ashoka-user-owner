class ActivateAllSuperAdmins < ActiveRecord::Migration
  def up
    User.where(:role => 'super_admin', :status => 'pending').each do |user|
      user.update_column(:status, 'active')
    end
  end

  def down
  end
end
