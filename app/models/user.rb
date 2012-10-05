class User < ActiveRecord::Base
  attr_accessible :email, :name, :password, :password_confirmation
  has_secure_password
  validates_presence_of :email, :name, :password_confirmation, :password
  validates_email_format_of :email
  validate :role_is_valid
  validates_uniqueness_of :email
  belongs_to :organization
  before_validation :default_values

  ROLES = %w(admin cso_admin user)

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

  private

  def role_is_valid
    errors.add(:role, "Invalid role specified") unless ROLES.include? role
  end

  def default_values
    self.role ||= "user"
    self.status ||= User::Status::PENDING
  end
end
