class RemoveColumnFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :password_reset_sent_at
  end

  def down
    add_column :users, :password_reset_sent_at, :datetime
  end
end
