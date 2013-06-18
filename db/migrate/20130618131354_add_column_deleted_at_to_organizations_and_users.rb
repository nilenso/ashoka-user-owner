class AddColumnDeletedAtToOrganizationsAndUsers < ActiveRecord::Migration
  def change
    add_column :organizations, :deleted_at, :date
    add_column :users, :deleted_at, :date
  end
end
