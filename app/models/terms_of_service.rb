class TermsOfService < ActiveRecord::Base
  validates_presence_of :document

  attr_accessible :document
  mount_uploader :document, DocumentUploader

  def self.latest
    order("created_at DESC").first
  end
end
