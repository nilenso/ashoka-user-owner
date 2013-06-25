class Organization < ActiveRecord::Base
  include SoftDeletable

  attr_accessible :name
  has_many :users
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_inclusion_of :default_locale, :in => I18n.available_locales.map(&:to_s)
  validates_inclusion_of :org_type, :in => proc { Organization.types }

  def active?
    status == Organization::Status::ACTIVE
  end

  def activate
    self.status = Status::ACTIVE
    self.save
  end

  def deactivate
    self.status = Status::INACTIVE
    self.save
  end

  def field_agents
    users.where(:role => 'field_agent')
  end

  def cso_admin
    users.find_by_role('cso_admin')
  end

  def self.types
    organization = YAML.load_file("#{Rails.root}/config/organization_types.yml")
    organization["types"].split(',').map(&:strip)
  end

  def self.build(org_params, cso_admin_params)
    organization = Organization.new(:name => org_params[:name])
    organization.org_type = org_params[:org_type]
    organization.allow_sharing = org_params[:allow_sharing]
    cso_admin = User.new(cso_admin_params)
    cso_admin.role = "cso_admin"
    cso_admin.status = User::Status::ACTIVE
    organization.users <<  cso_admin
    organization
  end

  def self.active_organizations
    where(:status => Status::ACTIVE)
  end

  def self.valid_ids?(org_ids)
    org_ids.all? { |org_id| exists?(org_id) }
  end

  module Status
    ACTIVE   = "active"
    INACTIVE = "inactive"
  end

  def soft_delete_self_and_associated
    users.each(&:soft_delete)
    self.soft_delete
  end
end
