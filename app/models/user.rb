class User < ActiveRecord::Base
  attr_accessible :email, :name, :password, :password_confirmation
  has_secure_password
  validates_presence_of :email, :name
  validates_presence_of :organization_id, :unless => :admin?
  validates_email_format_of :email
  validates_uniqueness_of :email
  belongs_to :organization

  ROLES = %w(admin cso_admin)

  private

  def admin?
    role == 'admin'
  end
end