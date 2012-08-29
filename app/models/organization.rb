class Organization < ActiveRecord::Base
  attr_accessible :name, :users_attributes
  has_many :users
  accepts_nested_attributes_for :users
  validates_presence_of :name

  def approved?
    status == "approved"
  end

  def rejected?
    status == "rejected"
  end
end
