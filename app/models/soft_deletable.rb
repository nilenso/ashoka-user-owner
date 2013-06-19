require 'active_support/concern'

module SoftDeletable
  extend ActiveSupport::Concern

  included do
    scope :not_deleted, where('deleted_at IS NULL')
    default_scope where('deleted_at IS NULL')
  end

  def soft_delete
    self.deleted_at = Date.today
    self.save
  end
end
