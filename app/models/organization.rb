class Organization < ActiveRecord::Base
  attr_accessible :name
  has_many :users
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_inclusion_of :default_locale, :in => I18n.available_locales.map(&:to_s)

  def approved?
    status == Organization::Status::APPROVED
  end

  def rejected?
    status == Organization::Status::REJECTED
  end

  def approve!
    if status == Status::REJECTED
      raise StandardError, "A rejected organization cannot be approved"
    else
      self.status = Status::APPROVED
      save!
    end
  end

  def reject!
    if status == Status::APPROVED
      raise StandardError, "A approved organization cannot be rejected"
    else
      self.status = Status::REJECTED
      save!
    end
  end

  def cso_users
    users.where(:role => 'user')
  end

  def cso_admin
    users.find_by_role('cso_admin')
  end

  def self.build(org_name, cso_admin_params)
    organization = Organization.new(:name => org_name)
    cso_admin = User.new(cso_admin_params)
    cso_admin.role = "cso_admin"
    organization.users <<  cso_admin
    organization
  end

  module Status
    APPROVED = "approved"
    PENDING = "pending"
    REJECTED = 'rejected'
  end
end
