class AddColumnDefaultLocaleToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :default_locale, :string
  end
end
