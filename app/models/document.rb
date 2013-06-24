require 'active_support/concern'

module Document
  extend ActiveSupport::Concern

  included do
    validates :document, :presence => true
    attr_accessible :document
    mount_uploader :document, DocumentUploader
  end

  module ClassMethods
    def latest
      order("created_at DESC").first
    end
  end
end
