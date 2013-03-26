class ActivateAllCsoAdmins < ActiveRecord::Migration
  def up
    User.where(:role => 'cso_admin', :status => 'pending').each do |user|
      user.update_column(:status, 'active')
    end
  end

  def down
  end
end
