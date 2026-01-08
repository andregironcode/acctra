class Cart < ApplicationRecord
    belongs_to :buyer, class_name: 'User'
    has_many :cart_items, dependent: :destroy
    enum status: { open: 'open', submitted: 'submitted' }

    scope :current_user_cart, ->(user) { where(buyer_id: user.id) }

    # Calculate the total price of all items in the cart
    # def total_price
    #   cart_items.includes(:product).sum { |item| item.total_price }
    # end
  end