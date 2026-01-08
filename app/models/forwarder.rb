class Forwarder < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :active, inclusion: { in: [true, false] }
  
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  
  def self.ransackable_attributes(auth_object = nil)
    ["name", "active", "created_at", "updated_at", "id"]
  end
  
  def self.ransackable_associations(auth_object = nil)
    []
  end
end