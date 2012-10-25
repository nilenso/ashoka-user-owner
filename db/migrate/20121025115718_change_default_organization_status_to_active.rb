class ChangeDefaultOrganizationStatusToActive < ActiveRecord::Migration
  def up
    change_column :organizations, :status, :string, :default => 'active'
  end

  def down
    change_column :organizations, :status, :string, :default => 'pending'
  end
end