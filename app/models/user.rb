class User < ActiveRecord::Base
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
  scope :active_users, where(:status => 'active')
  scope :inactive_users, where(:status => 'inactive')
  ROLES = %w(viewer field_agent supervisor designer manager cso_admin super_admin)

  ROLES.each do |role|
    define_method((role + "?").to_sym) do
      self.role == role
    end
  end

  def send_password_reset
    generate_password_reset_token
    UserMailer.password_reset_mail(self).deliver
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

  module Status
    ACTIVE = "active"
    PENDING = "pending"
    INACTIVE = "inactive"
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
