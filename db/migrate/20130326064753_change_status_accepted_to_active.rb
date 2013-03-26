class ChangeStatusAcceptedToActive < ActiveRecord::Migration
  def up
    User.where(:status => "accepted").each do |user|
      user.update_column :status, 'active'
    end
  end

  def down
    User.where(:status => "active").each do |user|
      user.update_column :status, 'accepted'
    end  
  end
end
