class SetOrgTypeForAllExistingOrganizations < ActiveRecord::Migration
  class TempOrganization < ActiveRecord::Base
    self.table_name = :organizations
  end

  def up
    organizations = TempOrganization.where(:org_type => nil)
    organizations.each do |organization|
      organization.org_type = 'CSO'
      organization.save
    end
  end

  def down
  end
end
