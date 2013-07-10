class User < ActiveRecord::Base
  include SoftDeletable

  attr_accessible :email, :name, :password, :password_confirmation, :role, :status
  has_secure_password
  validates_presence_of :email, :name
  validates_presence_of :password, :password_confirmation, :on => :create
  validates_email_format_of :email
  validate :role_is_valid
  validates_uniqueness_of :email,:case_sensitive => false
  belongs_to :organization
  before_validation :default_values
  before_save :convert_email_to_lower_case
  delegate :active?, :to => :organization, :prefix => true

  scope :super_admins, where(:role => "super_admin")

  ROLES = %w(viewer field_agent supervisor designer manager cso_admin super_admin)

  module Status
    ACTIVE = "active"
    PENDING = "pending"
    INACTIVE = "inactive"
  end

  scope :active_users,   where(:status => Status::ACTIVE)
  scope :pending_users,  where(:status => Status::PENDING)
  scope :inactive_users, where(:status => Status::INACTIVE)

  def self.maybe(user)
    user || NullUser.new
  end

  ROLES.each do |role|
    define_method((role + "?").to_sym) do
      self.role == role
    end
  end

  def active?
    status == Status::ACTIVE
  end

  def inactive?
    status == Status::INACTIVE
  end

  def send_password_reset
    generate_password_reset_token
    UserMailer.delay(:queue => "password_reset_mail").password_reset_mail(self)
  end

  def generate_password_reset_token
   begin
    self[:password_reset_token] = SecureRandom.urlsafe_base64
   end while User.exists?(:password_reset_token => self[:password_reset_token])
   save!
  end

  def reset_password(password, password_confirmation)
    return false if password.blank?
    self.password = password
    self.password_confirmation = password_confirmation
    self.password_reset_token = nil
    self.status = Status::ACTIVE
    save
  end

  def generate_password
    token = SecureRandom.urlsafe_base64
    self.password = token
    self.password_confirmation = token
  end

  def self.valid_ids?(user_ids)
    user_ids.all? { |user_id| exists?(user_id) }
  end

  def available_roles
    if role == "super_admin"
      ROLES
    else
      ROLES.reject { |role| role == 'super_admin' }
    end
  end

  private

  def convert_email_to_lower_case
    self.email = self.email.downcase
  end

  def role_is_valid
    errors.add(:role, "Invalid role specified") unless ROLES.include? role
  end

  def default_values
    self.role ||= "field_agent"
    self.status ||= User::Status::PENDING
  end
end

class NullUser
  %w(super_admin? active? organization_active?).each do |method|
    define_method(method.to_sym) do
      true
    end
  end

  def authenticate(*args)
    false
  end
end
