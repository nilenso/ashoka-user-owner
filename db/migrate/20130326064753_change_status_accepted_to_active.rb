class ChangeStatusAcceptedToActive < ActiveRecord::Migration
  class TempUser < ActiveRecord::Base
    self.table_name = :users
  end

  def up
    TempUser.where(:status => "accepted").each do |user|
      user.update_column :status, 'active'
    end
  end

  def down
    TempUser.where(:status => "active").each do |user|
      user.update_column :status, 'accepted'
    end
  end
end
