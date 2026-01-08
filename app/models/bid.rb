class Bid < ApplicationRecord
    belongs_to :buyer, class_name: 'User'
    belongs_to :inventory
    enum status: { pending: 'pending', accepted: 'accepted', rejected: 'rejected' }

    after_create_commit :send_bid_emails



    def self.sellers_bids(seller)
      Bid.joins(inventory: :seller).where(inventory: { seller_id: seller.id })
    end

    def self.ransackable_attributes(auth_object = nil)
      ["created_at", "id", "buyer_id", "quoted_price", "inventory_id", "updated_at" ,"offer_price", "accepted_price", "quantity", "status"]
    end

    def self.ransackable_associations(auth_object = nil)
      [" inventory, buyer"]
    end

    def self.seller_alert_count(seller)
      Bid.joins(inventory: :seller)
        .where(inventory: { seller_id: seller.id })
        .where(status: 'pending')
        .where('quoted_price IS NOT NULL AND offer_price IS NULL')
        .count
    end


    def self.buyers_count(buyer)
      Bid.where(buyer_id: buyer.id, alert: false).count
    end

    private

    def send_bid_emails
      seller = self.inventory.seller
      product_name = "#{self.inventory.product.name}   #{self.inventory.product.variant}"
      
      # Send email notifications
      BidMailer.with(
        email: seller.email, 
        product_name: product_name, 
        quantity: self.quantity, 
        amount: self.quoted_price, 
        time: self.created_at.strftime("%H:%M")
        ).new_bid_seller.deliver_now

      BidMailer.with(
      email: self.buyer.email, 
      product_name: product_name, 
      quantity: self.quantity, 
      amount: self.quoted_price, 
      time: self.created_at.strftime("%H:%M")
      ).new_bid_buyer.deliver_now

      # Send WhatsApp notification to seller
      send_whatsapp_notification_to_seller(seller, product_name)
    end

    def send_whatsapp_notification_to_seller(seller, product_name)
      WhatsappService.send_new_bid_notification(
        seller: seller,
        product_name: product_name,
        quantity: self.quantity,
        amount: self.quoted_price,
        time: self.created_at.strftime("%H:%M")
      )
    rescue => e
      Rails.logger.error "Failed to send WhatsApp notification for bid #{self.id}: #{e.message}"
    end
 
end