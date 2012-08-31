class User < ActiveRecord::Base
  attr_accessible :email, :name, :password, :password_confirmation
  has_secure_password
  validates_presence_of :email, :name, :password_confirmation, :password, :role
  validates_email_format_of :email
  validate :role_is_valid
  validates_uniqueness_of :email
  belongs_to :organization

  ROLES = %w(admin cso_admin user)

  def admin?
    role == 'admin'
  end

private

  def role_is_valid
    errors.add(:role, "Invalid role specified") unless ROLES.include? role
  end
end