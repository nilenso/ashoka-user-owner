class SetOrgTypeForAllExistingOrganizations < ActiveRecord::Migration
  def up
    organizations = Organization.where(:org_type => nil)
    organizations.each do |organization|
      organization.org_type = 'CSO'
      organization.save
    end
  end

  def down
  end
end
