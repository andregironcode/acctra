class User < ApplicationRecord
  has_many :inventories, foreign_key: :seller_id, dependent: :destroy
  has_many :products, through: :inventories
  has_one_attached :license
  has_one_attached :profile_image
  has_one :cart, foreign_key: :buyer_id, dependent: :destroy
  has_many :bids, foreign_key: :buyer_id, dependent: :destroy
  has_many :orders, foreign_key: :buyer_id, dependent: :destroy


  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Restrict ransackable attributes to specific fields
  def self.ransackable_attributes(auth_object = nil)
    %w[
      created_at
      email
      id
      role
      updated_at
      first_name
      last_name
      company_name
      address
      license_number
      website
      license
      approval_status
      country_code
      phone_number
    ]
  end

  # Restrict ransackable associations
  def self.ransackable_associations(auth_object = nil)
    %w[inventories products]
  end

  def full_name
    return first_name = self.first_name.to_s + " " + self.last_name.to_s
  end
  def is_buyer
    self.role == 'buyer'
  end

  def is_seller
    self.role == 'seller'
  end

  def self.todays_new_member
    where(created_at: Time.zone.today.all_day)
  end
  
  def contact_number
    return contact_number = self.country_code.to_s + " " + self.phone_number.to_s
  end

  validates :first_name, :last_name, presence: true
  # validates :contact_info, format: { with: /\A\+?[0-9]{7,15}\z/, message: "must be a valid phone number" }
  validates :company_name, length: { maximum: 50 }
  validates :license, attached: true, 
              content_type: { in: ['application/pdf'], message: 'must be a PDF' },
              size: { less_than: 5.megabytes, message: 'must be less than 5MB' }
  validates :profile_image, attached: true,
              content_type: { in: ['image/png', 'image/jpeg'], message: 'must be a PNG or JPEG' },
              size: { less_than: 10.megabytes, message: 'must be less than 10MB' },
              if: -> { profile_image.attached? }
            
  validates :country_code, presence: true
  validates :phone_number, presence: true, format: { with: /\A\d+\z/, message: "only allows numbers" }
  validates :password, presence: true, on: :create
  validates :password, confirmation: true, if: :password_required?
  before_validation :remove_leading_zero, if: :phone_number?

  scope :sellers, -> { where(role: 'seller').count }

  
  enum approval_status: { pending: 'pending', approved: 'approved', rejected: 'rejected' }
  validates :approval_status, inclusion: { in: approval_statuses.keys }

  def active_for_authentication?
    super && approved? && !suspended
  end

  def remove_leading_zero
    self.phone_number = phone_number.sub(/\A0/, '') if phone_number.start_with?('0')
  end

  def inactive_message
    return :not_approved unless approved?
    return :suspended if suspended?
    super
  end

  def password_required?
    new_record? || password.present?
  end

  def self.percentage_created_today
    today_count = where(created_at: Date.today.all_day).count
    yesterday_count = where(created_at: 1.day.ago.all_day).count
    total_count = today_count + yesterday_count
    total_count.positive? ? ((today_count.to_f / total_count) * 100).round(2) : 0.0
  end


  def full_phone_number
    "#{country_code}#{phone_number}"
  end

  def generate_otp!
    self.otp = rand(100000..999999).to_s
    self.otp_sent_at = Time.current
    save!
  end

  def otp_valid?(otp)
    self.otp == otp && otp_sent_at > 10.minutes.ago
  end

  def clear_otp!
    update!(otp: nil, otp_sent_at: nil)
  end
  
end