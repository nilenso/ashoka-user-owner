class User < ActiveRecord::Base
  attr_accessible :email, :name, :password, :password_confirmation, :role
  has_secure_password
  validates_presence_of :email, :name
  validates_presence_of :password, :password_confirmation, :on => :create
  validates_email_format_of :email
  validate :role_is_valid
  validates_uniqueness_of :email,:case_sensitive => false
  belongs_to :organization
  before_validation :default_values
  before_save :convert_email_to_lower_case
  scope :accepted_users, where(:status => 'accepted')
  ROLES = %w(admin cso_admin field_agent)

  def admin?
    role == 'admin'
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
    self.status = Status::ACCEPTED
    save
  end

  def generate_password
    token = SecureRandom.urlsafe_base64
    self.password = token
    self.password_confirmation = token
  end

  module Status
    ACCEPTED = "accepted"
    PENDING = "pending"
  end

  def self.valid_ids?(user_ids)
    user_ids.all? { |user_id| exists?(user_id) }
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
