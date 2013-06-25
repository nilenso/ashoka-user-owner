class AddColumnAllowSharingToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :allow_sharing, :boolean, :default => false
  end
end
