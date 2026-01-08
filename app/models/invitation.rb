# app/models/invitation.rb
# app/models/invitation.rb
class Invitation < ApplicationRecord
  belongs_to :user, optional: true
  before_create :generate_token
  before_create :set_expiration

  scope :expired, -> { where('expires_at < ?', Time.current) }
  scope :active, -> { where('expires_at > ?', Time.current) }

  def expired?
    expires_at < Time.current
  end

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "email", "id", "role", "token", "updated_at", "user_id", "expires_at"]
  end

  private

  def generate_token
    self.token = SecureRandom.hex(10)
  end

  def set_expiration
    self.expires_at = 24.hours.from_now
  end
end