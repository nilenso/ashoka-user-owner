class AddColumnStatusRemoveColumnApprovedFromOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :status, :string, :default => "pending"
    remove_column :organizations, :approved
  end
end
