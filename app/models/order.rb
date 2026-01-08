class Order < ApplicationRecord
    belongs_to :buyer, class_name: 'User'
    has_many :order_items, dependent: :destroy
    has_one :pre_order_inspection, dependent: :destroy
    has_many :order_product_details, dependent: :destroy
    accepts_nested_attributes_for :order_items, allow_destroy: true

    enum status: { created: "new", processing: 'processing', dispatched: 'dispatched', completed: 'completed' }
    
    after_create_commit :send_order_notifications

    validates :buyer, presence: true
    validates :status, presence: true
    validates :total_amount, presence: true, numericality: true
    scope :pending_orders, -> { where(status: :processing) }

    # Methods for export formats
    def buyer_name
      buyer&.full_name
    end
    
    def seller_names
      order_items.includes(inventory: :seller).map do |item|
        item.inventory&.seller&.full_name
      end.compact.uniq
    end

    def self.ransackable_attributes(auth_object = nil)
      ["created_at", "id", "id_value", "status", "updated_at", "buyer_id", "total_amount"]
    end
    
    def self.ransackable_associations(auth_object = nil)
      ["buyer", "order_items", "pre_order_inspection"]
    end

    def self.total_sales
      where(status: 'completed').sum(:total_amount)
    end

    def self.todays_total_sales
      where(status: 'completed', created_at: Time.zone.today.all_day).sum(:total_amount)
    end

    def self.total_sellers_orders(seller)
      orders = Order.joins(order_items: :inventory)
                              .where(inventories: { seller_id: seller.id }).distinct
    end

    def self.sales_orders(seller)
      orders = Order.joins(order_items: :inventory)
                    .where(inventories: { seller_id: seller.id })
                    .where(orders: { is_approve: true })
                    .distinct
    end

    def self.todays_orders(seller = nil)
      orders = Order.joins(order_items: :inventory)
                    .where(created_at: Time.zone.today.all_day, status: 'completed')
                    .distinct
      orders = orders.where(inventories: { seller_id: seller.id }) if seller.present?
    
      orders
    end
    
    def self.todays_all_orders(seller = nil)
      orders = Order.joins(order_items: :inventory)
                    .where(created_at: Time.zone.today.all_day)
                    .distinct
      orders = orders.where(inventories: { seller_id: seller.id }) if seller.present?
    
      orders
    end

    def self.percentage_change_in_orders(seller = nil, type= '')
      end_of_today = Time.zone.now.end_of_day
      start_of_today = Time.zone.now.beginning_of_day
      orders_today = orders_count_for_period(seller, start_of_today, end_of_today)
  
      start_of_yesterday = (Time.zone.now - 1.day).beginning_of_day
      end_of_yesterday = (Time.zone.now - 1.day).end_of_day
      orders_yesterday = orders_count_for_period(seller, start_of_yesterday, end_of_yesterday)
      if type == 'orders'
          if orders_yesterday.count > 0
            percentage_change = ((orders_today.count - orders_yesterday.count).to_f / orders_yesterday.count) * 100
          else
            percentage_change = 0
          end
        percentage_change.round(2)
      elsif type == 'sales'
        todays_sales = orders_today.where(status: 'completed').sum(&:total_amount)
        yesterdays_sales = orders_yesterday.where(status: 'completed').sum(&:total_amount)    
        if yesterdays_sales > 0
          percentage_change = ((todays_sales - yesterdays_sales) / yesterdays_sales) * 100
        else
          percentage_change = 0
        end
        return percentage_change.round(2)

      elsif type == 'processing'
        todays_pending_orders = orders_today.where(status: "processing")
        yesterdays_pending_orders = orders_yesterday.where(status: "processing")
    
        if yesterdays_pending_orders.count > 0
          percentage_change = ((todays_pending_orders.count - yesterdays_pending_orders.count) / yesterdays_pending_orders.count) * 100
        else
          percentage_change = 0
        end
        return percentage_change.round(2)
    elsif type == 'completed'
      todays_confirmed_orders = orders_today.where(status: "completed")
      yesterdays_confirmed_orders = orders_yesterday.where(status: "completed")
  
      if yesterdays_confirmed_orders.count > 0
        percentage_change = ((todays_confirmed_orders.count - yesterdays_confirmed_orders.count) / yesterdays_confirmed_orders.count) * 100
      else
        percentage_change = 0
      end
      return percentage_change.round(2)
    end
      
    end

    def self.orders_count_for_period(seller = nil, start_time, end_time)
      query = Order.joins(order_items: :inventory)
      query = query.where(inventories: { seller_id: seller.id }) if seller
      query.where("orders.created_at >= ? AND orders.created_at < ?", start_time, end_time).distinct
    end

    def self.top_sellers(start_date = nil, end_date = Time.zone.now)
      top_sellers = joins(order_items: :inventory)
                   .joins('JOIN users ON users.id = inventories.seller_id')
                   .where(orders: { status: 'completed' })
                   .where.not(inventories: { seller_id: nil })
      
      if start_date.present?
        top_sellers = top_sellers.where('orders.created_at BETWEEN ? AND ?', start_date, end_date)
      else
        top_sellers = top_sellers.where('orders.created_at <= ?', end_date)
      end
    
      top_sellers = top_sellers
                    .select('inventories.seller_id, users.first_name, users.last_name, users.id, SUM(order_items.quantity * inventories.price) AS total_revenue')
                    .group('inventories.seller_id, users.first_name, users.last_name, users.id')
                    .order('total_revenue DESC')
                    .limit(10)
      
      top_sellers.to_a
    end
    
    private

    def send_order_notifications
      # Get all unique sellers from this order
      sellers = order_items.includes(inventory: :seller).map { |item| item.inventory.seller }.uniq.compact
      
      sellers.each do |seller|
        send_whatsapp_notification_to_seller(seller)
      end
    end

    def send_whatsapp_notification_to_seller(seller)
      WhatsappService.send_new_order_notification(
        seller: seller,
        order_amount: total_amount,
        total_items: order_items.sum(:quantity),
        time: created_at.strftime("%H:%M")
      )
    rescue => e
      Rails.logger.error "Failed to send WhatsApp order notification for order #{id} to seller #{seller.id}: #{e.message}"
    end
    
end