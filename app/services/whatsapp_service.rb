class WhatsappService
  require 'twilio-ruby'
  
  class << self
    def client
      @client ||= Twilio::REST::Client.new(
        ENV['TWILIO_ACCOUNT_SID'],
        ENV['TWILIO_AUTH_TOKEN']
      )
    end
    
    def send_message(to:, message:)
      raise ArgumentError, "Phone number is required" if to.blank?
      raise ArgumentError, "Message is required" if message.blank?
      raise ConfigurationError, "Twilio credentials not configured" unless configured?
      
      # Normalize and validate phone number
      normalized_number = normalize_phone_number(to)
      
      # Ensure phone number has whatsapp: prefix
      to_number = normalized_number.start_with?('whatsapp:') ? normalized_number : "whatsapp:#{normalized_number}"
      from_number = "whatsapp:#{ENV['TWILIO_WHATSAPP_NUMBER']}"
      
      Rails.logger.info "Sending WhatsApp message from #{from_number} to #{to_number}"
      
      client.messages.create(
        from: from_number,
        to: to_number,
        body: message
      )
    rescue Twilio::REST::RestError => e
      Rails.logger.error "Twilio WhatsApp Error: #{e.message} (Code: #{e.code})"
      raise TwilioError.new(e.message, e.code)
    rescue => e
      Rails.logger.error "WhatsApp Service Error: #{e.message}"
      raise
    end
    
    def send_order_notification(order_id:, phone_number:, customer_name: nil)
      customer_greeting = customer_name ? "Hi #{customer_name}!\n\n" : ""
      
      message = <<~MSG
        #{customer_greeting}📦 Order Update from Acctra
        
        Your order ##{order_id} has been processed successfully!
        
        We'll keep you updated on the shipping status.
        
        Thank you for choosing Acctra for your mobile device needs! 📱
        
        Questions? Contact our support team.
      MSG
      
      send_message(to: phone_number, message: message)
    end
    
    def send_order_shipped_notification(order_id:, phone_number:, tracking_number: nil)
      tracking_info = tracking_number ? "\n\nTracking Number: #{tracking_number}" : ""
      
      message = <<~MSG
        🚚 Shipping Update - Acctra
        
        Great news! Your order ##{order_id} has been shipped!#{tracking_info}
        
        You should receive your mobile devices soon.
        
        Thank you for your business! 📱✨
      MSG
      
      send_message(to: phone_number, message: message)
    end
    
    def send_bid_notification(bid_amount:, product_name:, phone_number:, buyer_name: nil)
      greeting = buyer_name ? "Hi #{buyer_name}!\n\n" : ""
      
      message = <<~MSG
        #{greeting}💰 New Bid Alert - Acctra
        
        A new bid of $#{bid_amount} has been placed on:
        #{product_name}
        
        Check your dashboard to review and respond to this bid.
        
        Happy trading! 📱💼
      MSG
      
      send_message(to: phone_number, message: message)
    end
    
    def send_welcome_message(phone_number:, user_name:)
      message = <<~MSG
        Welcome to Acctra, #{user_name}! 🎉
        
        You're now part of our mobile device trading platform.
        
        • Browse quality devices 📱
        • Make competitive bids 💰
        • Track your orders 📦
        
        Start exploring: #{ENV['DEFAULT_URL'] || 'https://acctra.com'}
        
        Need help? We're here for you! 💬
      MSG
      
      send_message(to: phone_number, message: message)
    end
    
    # Send message to whatsapp number using a twilio template
    def send_templated_message(to:, params: {
      product: nil,
      amount: nil,
      quantity: nil,
      time: nil
    })
      raise ArgumentError, "Phone number is required" if to.blank?
      raise ConfigurationError, "Twilio template credentials not configured" unless template_configured?

      # logs the parameters being sent
      puts "Sending templated WhatsApp message to #{to} with params: #{params.to_json}"

      # Normalize phone number
      normalized_number = normalize_phone_number(to)
      to_number = normalized_number.start_with?('whatsapp:') ? normalized_number : "whatsapp:#{normalized_number}"
      from_number = "whatsapp:#{ENV['TWILIO_WHATSAPP_NUMBER']}"

      message = client
          .api
          .v2010
          .messages
          .create(
            content_sid: ENV['MESSAGE_TEMPLATE_SID'],
            to: to_number,
            from: from_number,
            content_variables: params.to_json,
            messaging_service_sid: ENV['TWILIO_MESSAGING_SERVICE_SID']
          )

      Rails.logger.info "Templated WhatsApp message sent: #{message.sid}"
      
      puts message.body
      message
    rescue Twilio::REST::RestError => e
      Rails.logger.error "Twilio WhatsApp Template Error: #{e.message} (Code: #{e.code})"
      raise TwilioError.new(e.message, e.code)
    rescue => e
      Rails.logger.error "WhatsApp Template Service Error: #{e.message}"
      raise
    end
    
    def send_new_bid_notification(seller:, product_name:, quantity:, amount:, time:)
      return false unless seller&.phone_number.present?
      
      begin
        phone_number = seller.full_phone_number
        
        # Try to send using template first
        begin
          send_bid_template_message(
            to: phone_number,
            product_name: product_name,
            amount: amount,
            quantity: quantity,
            time: time
          )
          Rails.logger.info "WhatsApp bid template notification sent to seller #{seller.id} at #{phone_number}"
          true
        rescue => template_error
          Rails.logger.warn "Template message failed, falling back to regular message: #{template_error.message}"
          
          # Fallback to regular message
          message = "🔔 New Bid Alert!\n\n" \
                    "You have received a new bid for:\n" \
                    "📦 Product: #{product_name}\n" \
                    "🔢 Quantity: #{quantity}\n" \
                    "💰 Bid Amount: KES #{amount}\n" \
                    "⏰ Time: #{time}\n\n" \
                    "Please log in to your account to review and respond to this bid."
          
          send_message(to: phone_number, message: message)
          Rails.logger.info "WhatsApp bid fallback notification sent to seller #{seller.id} at #{phone_number}"
          true
        end
      rescue => e
        Rails.logger.error "Failed to send WhatsApp bid notification to seller #{seller.id}: #{e.message}"
        false
      end
    end
    
    # Send bid notification using the template
    def send_bid_template_message(to:, product_name:, amount:, quantity:, time:)
      raise ArgumentError, "Phone number is required" if to.blank?
      raise ConfigurationError, "Twilio bid template not configured" unless bid_template_configured?

      # Normalize phone number
      normalized_number = normalize_phone_number(to)
      to_number = normalized_number.start_with?('whatsapp:') ? normalized_number : "whatsapp:#{normalized_number}"
      from_number = "whatsapp:#{ENV['TWILIO_WHATSAPP_NUMBER']}"

      # Template parameters matching the structure:
      # {{1}} = Product name
      # {{2}} = Bid amount
      # {{3}} = Quantity
      # {{4}} = Time/validity
      template_params = {
        "1": product_name,
        "2": amount.to_s,
        "3": quantity.to_s,
        "4": time
      }

      Rails.logger.info "Sending bid template WhatsApp message to #{to_number} with params: #{template_params.to_json}"

      message = client
          .api
          .v2010
          .messages
          .create(
            content_sid: ENV['BID_PLACED_TEMPLATE_SID'],
            to: to_number,
            from: from_number,
            content_variables: template_params.to_json,
            messaging_service_sid: ENV['TWILIO_MESSAGING_SERVICE_SID']
          )

      Rails.logger.info "Bid template WhatsApp message sent: #{message.sid}"
      message
    rescue Twilio::REST::RestError => e
      Rails.logger.error "Twilio WhatsApp Bid Template Error: #{e.message} (Code: #{e.code})"
      raise TwilioError.new(e.message, e.code)
    rescue => e
      Rails.logger.error "WhatsApp Bid Template Service Error: #{e.message}"
      raise
    end
    
    # Send order notification using the template
    def send_order_template_message(to:, order_amount:, total_items:, time:)
      raise ArgumentError, "Phone number is required" if to.blank?
      raise ConfigurationError, "Twilio order template not configured" unless order_template_configured?
      raise ConfigurationError, "Twilio service not configured" unless configured?

      # Normalize phone number
      normalized_number = normalize_phone_number(to)
      to_number = normalized_number.start_with?('whatsapp:') ? normalized_number : "whatsapp:#{normalized_number}"
      from_number = "whatsapp:#{ENV['TWILIO_WHATSAPP_NUMBER']}"

      # Template parameters matching the structure:
      # {{1}} = Order amount
      # {{2}} = Total items
      # {{3}} = Time
      template_params = {
        "1": order_amount.to_s,
        "2": total_items.to_s,
        "3": time
      }

      Rails.logger.info "Sending order template WhatsApp message to #{to_number} with params: #{template_params.to_json}"

      message = client
          .api
          .v2010
          .messages
          .create(
            content_sid: ENV['ORDER_PLACED_TEMPLATE_SID'],
            to: to_number,
            from: from_number,
            content_variables: template_params.to_json,
            messaging_service_sid: ENV['TWILIO_MESSAGING_SERVICE_SID']
          )

      Rails.logger.info "Order template WhatsApp message sent: #{message.sid}"
      message
    rescue Twilio::REST::RestError => e
      Rails.logger.error "Twilio WhatsApp Order Template Error: #{e.message} (Code: #{e.code})"
      raise TwilioError.new(e.message, e.code)
    rescue => e
      Rails.logger.error "WhatsApp Order Template Service Error: #{e.message}"
      raise
    end

    # Send WhatsApp notification to seller when a new order is placed
    def send_new_order_notification(seller:, order_amount:, total_items:, time:)
      return false unless seller&.phone_number.present?
      
      begin
        phone_number = seller.full_phone_number
        
        # Try to send using template first
        begin
          send_order_template_message(
            to: phone_number,
            order_amount: order_amount,
            total_items: total_items,
            time: time
          )
          Rails.logger.info "WhatsApp order template notification sent to seller #{seller.id} at #{phone_number}"
          true
        rescue => template_error
          Rails.logger.warn "Order template message failed, falling back to regular message: #{template_error.message}"
          
          # Fallback to regular message
          message = "🔔 New Order Alert!\n\n" \
                    "You have received a new order:\n" \
                    "💰 Order Amount: $#{order_amount}\n" \
                    "📦 Total Items: #{total_items}\n" \
                    "⏱️ Time: #{time}\n\n" \
                    "Please log in to your account to review and process this order."
          
          send_message(to: phone_number, message: message)
          Rails.logger.info "WhatsApp order fallback notification sent to seller #{seller.id} at #{phone_number}"
          true
        end
      rescue => e
        Rails.logger.error "Failed to send WhatsApp order notification to seller #{seller.id}: #{e.message}"
        false
      end
    end
    
    def configured?
      ENV['TWILIO_ACCOUNT_SID'].present? &&
      ENV['TWILIO_AUTH_TOKEN'].present? &&
      ENV['TWILIO_WHATSAPP_NUMBER'].present?
    end

    def template_configured?
      configured? &&
      ENV['MESSAGE_TEMPLATE_SID'].present? &&
      ENV['TWILIO_MESSAGING_SERVICE_SID'].present?
    end
    
    def bid_template_configured?
      configured? &&
      ENV['BID_PLACED_TEMPLATE_SID'].present? &&
      ENV['TWILIO_MESSAGING_SERVICE_SID'].present?
    end
    
    def order_template_configured?
      configured? &&
      ENV['ORDER_PLACED_TEMPLATE_SID'].present? &&
      ENV['TWILIO_MESSAGING_SERVICE_SID'].present?
    end
    
    def configuration_status
      {
        account_sid: ENV['TWILIO_ACCOUNT_SID'].present?,
        auth_token: ENV['TWILIO_AUTH_TOKEN'].present?,
        whatsapp_number: ENV['TWILIO_WHATSAPP_NUMBER'].present?,
        message_template_sid: ENV['MESSAGE_TEMPLATE_SID'].present?,
        bid_template_sid: ENV['BID_PLACED_TEMPLATE_SID'].present?,
        order_template_sid: ENV['ORDER_PLACED_TEMPLATE_SID'].present?,
        messaging_service_sid: ENV['TWILIO_MESSAGING_SERVICE_SID'].present?,
        configured: configured?,
        template_configured: template_configured?,
        bid_template_configured: bid_template_configured?,
        order_template_configured: order_template_configured?
      }
    end
    
    def test_kenyan_number
      # Specific test for Kenyan number format
      send_message(
        to: "+254719459405",
        message: "Hello from Acctra! 🇰🇪\n\nThis is a test message to your Kenyan number.\n\nYour WhatsApp integration is working! 🚀📱"
      )
    end
    

    def test_templated_message(phone_number)
      # Test sending a templated message
      send_templated_message(
        to: phone_number,
        params: {
          "1": "Samsung Galaxy S21",
          "2": "500",
          "3": "1",
          "4": "2 days"
        }
      )
    end
    
    def test_bid_template_message(phone_number, product_name = "iPhone 14 Pro", amount = 1500, quantity = 2, time = "2 hours")
      # Test sending a bid template message
      send_bid_template_message(
        to: phone_number,
        product_name: product_name,
        amount: amount,
        quantity: quantity,
        time: time
      )
    end
    
    def test_order_template_message(phone_number, order_amount = 2500, total_items = 3, time = "14:30")
      # Test sending an order template message
      send_order_template_message(
        to: phone_number,
        order_amount: order_amount,
        total_items: total_items,
        time: time
      )
    end
    
    private

    def normalize_phone_number(phone)
      # Remove any spaces, dashes, or parentheses
      normalized = phone.gsub(/[\s\-\(\)]/, '')
      
      # Handle Kenyan numbers specifically
      if normalized.match?(/^(?:0)?7\d{8}$/) # Kenyan mobile format
        normalized = "+254#{normalized.sub(/^0/, '')}"
      elsif normalized.match?(/^254\d{9}$/) # Kenyan without +
        normalized = "+#{normalized}"
      elsif !normalized.start_with?('+')
        # Ensure it starts with + for other international numbers
        normalized = "+#{normalized}"
      end
      
      # Validate international format
      unless normalized.match?(/^\+[1-9]\d{1,14}$/)
        raise ArgumentError, "Invalid phone number format: #{phone}. Please use international format (+254719459405)"
      end
      
      normalized
    end
  end
  
  # Custom error classes
  class ConfigurationError < StandardError; end
  class TwilioError < StandardError
    attr_reader :code
    
    def initialize(message, code = nil)
      super(message)
      @code = code
    end
  end
end
