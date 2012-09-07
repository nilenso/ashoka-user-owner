class ChangeColumnDefaultLocaleToAddDefaultValueInOrganization < ActiveRecord::Migration
  def up
    change_column(:organizations, :default_locale, :string, :default => I18n.default_locale)
  end

  def down
    change_column(:organizations, :default_locale, :string)
  end
end
