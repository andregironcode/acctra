namespace :whatsapp do
  desc "Test WhatsApp message sending via Twilio"
  task :test_message, [:phone_number, :message] => :environment do |t, args|
    require 'twilio-ruby'
    
    # Default values
    phone_number = args[:phone_number] || ENV['TEST_PHONE_NUMBER'] || '+1234567890'
    message = args[:message] || 'Hello from Acctra! This is a test message from our WhatsApp integration via rake task.'
    
    puts "🚀 Testing WhatsApp message sending..."
    puts "📱 To: #{phone_number}"
    puts "💬 Message: #{message}"
    puts "=" * 50
    
    begin
      # Check environment variables
      if ENV['TWILIO_ACCOUNT_SID'].blank?
        puts "❌ Error: TWILIO_ACCOUNT_SID not found in environment variables"
        exit 1
      end
      
      if ENV['TWILIO_AUTH_TOKEN'].blank?
        puts "❌ Error: TWILIO_AUTH_TOKEN not found in environment variables"
        exit 1
      end
      
      if ENV['TWILIO_WHATSAPP_NUMBER'].blank?
        puts "❌ Error: TWILIO_WHATSAPP_NUMBER not found in environment variables"
        exit 1
      end
      
      # Initialize Twilio client
      client = Twilio::REST::Client.new(
        ENV['TWILIO_ACCOUNT_SID'],
        ENV['TWILIO_AUTH_TOKEN']
      )
      
      puts "✅ Twilio client initialized successfully"
      puts "📞 From: #{ENV['TWILIO_WHATSAPP_NUMBER']}"
      
      # Send WhatsApp message
      message_response = client.messages.create(
        from: "whatsapp:#{ENV['TWILIO_WHATSAPP_NUMBER']}",
        to: "whatsapp:#{phone_number}",
        body: message
      )
      
      puts "=" * 50
      puts "✅ SUCCESS! WhatsApp message sent successfully!"
      puts "📋 Message Details:"
      puts "   • Message SID: #{message_response.sid}"
      puts "   • Status: #{message_response.status}"
      puts "   • Direction: #{message_response.direction}"
      puts "   • Date Created: #{message_response.date_created}"
      puts "   • Price: #{message_response.price || 'N/A'}"
      puts "   • Error Code: #{message_response.error_code || 'None'}"
      puts "   • Error Message: #{message_response.error_message || 'None'}"
      
    rescue Twilio::REST::RestError => e
      puts "=" * 50
      puts "❌ Twilio API Error:"
      puts "   • Code: #{e.code}"
      puts "   • Message: #{e.message}"
      puts "   • More Info: #{e.more_info}"
      exit 1
      
    rescue => e
      puts "=" * 50
      puts "❌ General Error: #{e.message}"
      puts "   • Class: #{e.class}"
      puts "   • Backtrace: #{e.backtrace.first(3).join("\n   ")}"
      exit 1
    end
  end
  
  desc "Test order notification WhatsApp message"
  task :test_order_notification, [:phone_number, :order_id] => :environment do |t, args|
    require 'twilio-ruby'
    
    phone_number = args[:phone_number] || ENV['TEST_PHONE_NUMBER'] || '+1234567890'
    order_id = args[:order_id] || '12345'
    
    message = <<~MSG
      📦 Order Update from Acctra
      
      Your order ##{order_id} has been processed!
      
      Thank you for choosing Acctra for your mobile device needs.
      
      For questions, contact our support team.
    MSG
    
    puts "🚀 Testing Order Notification WhatsApp message..."
    puts "📱 To: #{phone_number}"
    puts "📦 Order ID: #{order_id}"
    puts "=" * 50
    
    begin
      client = Twilio::REST::Client.new(
        ENV['TWILIO_ACCOUNT_SID'],
        ENV['TWILIO_AUTH_TOKEN']
      )
      
      message_response = client.messages.create(
        from: "whatsapp:#{ENV['TWILIO_WHATSAPP_NUMBER']}",
        to: "whatsapp:#{phone_number}",
        body: message
      )
      
      puts "✅ SUCCESS! Order notification sent successfully!"
      puts "📋 Message SID: #{message_response.sid}"
      puts "📋 Status: #{message_response.status}"
      
    rescue => e
      puts "❌ Error: #{e.message}"
      exit 1
    end
  end
  
  desc "Check Twilio configuration"
  task :check_config => :environment do
    puts "🔧 Checking Twilio WhatsApp Configuration..."
    puts "=" * 50
    
    config_items = [
      ['TWILIO_ACCOUNT_SID', ENV['TWILIO_ACCOUNT_SID']],
      ['TWILIO_AUTH_TOKEN', ENV['TWILIO_AUTH_TOKEN']],
      ['TWILIO_WHATSAPP_NUMBER', ENV['TWILIO_WHATSAPP_NUMBER']],
      ['TWILIO_PHONE_NUMBER', ENV['TWILIO_PHONE_NUMBER']]
    ]
    
    config_items.each do |name, value|
      if value.present?
        if name == 'TWILIO_AUTH_TOKEN'
          puts "✅ #{name}: #{'*' * 8}#{value.last(4)} (hidden for security)"
        else
          puts "✅ #{name}: #{value}"
        end
      else
        puts "❌ #{name}: Not configured"
      end
    end
    
    puts "=" * 50
    
    if config_items.first(3).all? { |_, value| value.present? }
      puts "✅ All required Twilio configurations are present!"
      puts "💡 You can now test WhatsApp messaging."
    else
      puts "❌ Missing required Twilio configuration."
      puts "💡 Please check your .env file and ensure all Twilio variables are set."
    end
  end
  
  desc "Show usage examples"
  task :help do
    puts <<~HELP
      🔧 WhatsApp Testing Rake Tasks
      ==============================
      
      1. Check Configuration:
         rake whatsapp:check_config
      
      2. Test Basic Message:
         rake whatsapp:test_message[+1234567890,"Hello World"]
      
      3. Test Order Notification:
         rake whatsapp:test_order_notification[+1234567890,12345]
      
      4. Using environment variable for phone:
         TEST_PHONE_NUMBER=+1234567890 rake whatsapp:test_message
      
      📝 Notes:
      • Phone numbers must include country code (e.g., +1234567890)
      • Make sure your .env file has all required Twilio variables
      • The WhatsApp number must be verified with Twilio
      
      🌐 Web Interface:
      Visit http://localhost:3000/whatsapp/test for a web-based testing interface
    HELP
  end

  desc "Test WhatApp message using a Templated Message"
  task :test_templated_message, [:phone_number] => :environment do |t, args|
    require 'twilio-ruby'
    
    phone_number = args[:phone_number] || ENV['TEST_PHONE_NUMBER'] || '+1234567890'
    
    puts "🚀 Testing WhatsApp templated message..."
    puts "📱 To: #{phone_number}"
    puts "=" * 50
    
    begin
      # Check configuration first
      unless WhatsappService.configured?
        puts "❌ Twilio not configured properly"
        Rake::Task['whatsapp:check_config'].invoke
        exit 1
      end
      
      # Send templated message
      message = WhatsappService.test_templated_message(phone_number)
      
      puts "✅ SUCCESS! Templated message sent to #{phone_number}"
      puts "📋 Message SID: #{message.sid}"
      puts "📋 Status: #{message.status}"
      puts "📋 Direction: #{message.direction}"
      puts
      puts "🎉 Check your WhatsApp for the templated message!"
      
    rescue WhatsappService::TwilioError => e
      puts "❌ Twilio Error (#{e.code}): #{e.message}"
      
      case e.code.to_i
      when 20003
        puts "\n🔧 This is an authentication error. Solutions:"
        puts "   1. Verify your Twilio Account SID and Auth Token"
        puts "   2. Check if your Twilio account is active"
        puts "   3. Regenerate your Auth Token in Twilio Console"
      when 63016
        puts "\n🔧 WhatsApp not enabled. Solutions:"
        puts "   1. Enable WhatsApp Sandbox in Twilio Console"
        puts "   2. Join the sandbox by messaging 'join <keyword>' to your Twilio number"
        puts "   3. Add +254719459405 to your sandbox whitelist"
      when 21614
        puts "\n🔧 Invalid phone number. Solutions:"
        puts "   1. Ensure +254719459405 is a valid WhatsApp number"
        puts "   2. Try with a different test number"
      else
        puts "\n🔧 Check Twilio documentation for error #{e.code}"
      end
      
    rescue => e
      puts "❌ Error: #{e.message}"
    end
  end
  
  desc "Test WhatsApp message to Kenyan number +254719459405"
  task :test_kenyan_number => :environment do
    puts "🇰🇪 Testing WhatsApp message to Kenyan number..."
    puts "📱 To: +254719459405"
    puts "=" * 50
    
    begin
      # Check configuration first
      unless WhatsappService.configured?
        puts "❌ Twilio not configured properly"
        Rake::Task['whatsapp:check_config'].invoke
        exit 1
      end
      
      # Send test message
      message = WhatsappService.test_kenyan_number
      
      puts "✅ SUCCESS! Message sent to +254719459405"
      puts "📋 Message SID: #{message.sid}"
      puts "📋 Status: #{message.status}"
      puts "📋 Direction: #{message.direction}"
      puts
      puts "🎉 Check your WhatsApp for the test message!"
      
    rescue WhatsappService::TwilioError => e
      puts "❌ Twilio Error (#{e.code}): #{e.message}"
      
      case e.code.to_i
      when 20003
        puts "\n🔧 This is an authentication error. Solutions:"
        puts "   1. Verify your Twilio Account SID and Auth Token"
        puts "   2. Check if your Twilio account is active"
        puts "   3. Regenerate your Auth Token in Twilio Console"
      when 63016
        puts "\n🔧 WhatsApp not enabled. Solutions:"
        puts "   1. Enable WhatsApp Sandbox in Twilio Console"
        puts "   2. Join the sandbox by messaging 'join <keyword>' to your Twilio number"
        puts "   3. Add +254719459405 to your sandbox whitelist"
      when 21614
        puts "\n🔧 Invalid phone number. Solutions:"
        puts "   1. Ensure +254719459405 is a valid WhatsApp number"
        puts "   2. Try with a different test number"
      else
        puts "\n🔧 Check Twilio documentation for error #{e.code}"
      end
      
    rescue => e
      puts "❌ Error: #{e.message}"
    end
  end

  desc "Test WhatsApp bid notification"
  task test_bid_notification: :environment do
    # Find a seller with a phone number
    seller = User.joins(:inventories).where.not(phone_number: nil).first
    
    if seller.nil?
      puts "No seller with phone number found"
      exit
    end
    
    # Get one of their products
    inventory = seller.inventories.joins(:product).first
    
    if inventory.nil?
      puts "No inventory found for seller"
      exit
    end
    
    product_name = "#{inventory.product.name} #{inventory.product.variant}"
    
    puts "Testing WhatsApp bid notification..."
    puts "Seller: #{seller.email}"
    puts "Phone: #{seller.full_phone_number}"
    puts "Product: #{product_name}"
    
    success = WhatsappService.send_new_bid_notification(
      seller: seller,
      product_name: product_name,
      quantity: 5,
      amount: 1000,
      time: Time.current.strftime("%H:%M")
    )
    
    if success
      puts "✅ WhatsApp bid notification sent successfully!"
    else
      puts "❌ Failed to send WhatsApp bid notification"
    end
  end

  desc "Test bid creation with WhatsApp notification"
  task test_bid_creation_with_whatsapp: :environment do
    # Find a seller with a phone number and inventory
    seller = User.joins(:inventories).where.not(phone_number: nil).first
    
    if seller.nil?
      puts "No seller with phone number found"
      exit
    end
    
    # Find a buyer (different from seller)
    buyer = User.where.not(id: seller.id).first
    
    if buyer.nil?
      puts "No buyer found"
      exit
    end
    
    # Get seller's inventory
    inventory = seller.inventories.first
    
    if inventory.nil?
      puts "No inventory found for seller"
      exit
    end
    
    puts "Testing bid creation with WhatsApp notification..."
    puts "Seller: #{seller.email} (#{seller.full_phone_number})"
    puts "Buyer: #{buyer.email}"
    puts "Inventory: #{inventory.product.name} #{inventory.product.variant}"
    
    # Create a test bid
    bid = Bid.create!(
      buyer: buyer,
      inventory: inventory,
      quoted_price: 1500,
      quantity: 3,
      status: 'pending'
    )
    
    if bid.persisted?
      puts "✅ Bid created successfully (ID: #{bid.id})"
      puts "✅ Email and WhatsApp notifications should have been sent automatically"
    else
      puts "❌ Failed to create bid"
      puts bid.errors.full_messages.join(", ")
    end
  end

  desc "Test WhatsApp bid template message"
  task test_bid_template: :environment do
    phone_number = ENV['TEST_PHONE_NUMBER'] || "+254719459405"
    
    puts "Testing WhatsApp bid template message..."
    puts "Phone number: #{phone_number}"
    puts "Template SID: #{ENV['BID_PLACED_TEMPLATE_SID']}"
    puts "Messaging Service SID: #{ENV['TWILIO_MESSAGING_SERVICE_SID']}"
    
    begin
      result = WhatsappService.test_bid_template_message(
        phone_number,
        "Samsung Galaxy S23 Ultra - 512GB",
        25000,
        1,
        "24 hours"
      )
      puts "✅ Bid template message sent successfully!"
      puts "Message SID: #{result.sid}"
    rescue => e
      puts "❌ Error: #{e.message}"
      puts "Error class: #{e.class}"
    end
  end

  desc "Check users with phone numbers"
  task check_users_with_phones: :environment do
    users_with_phones = User.where.not(phone_number: nil).where.not(phone_number: '')
    puts "Users with phone numbers: #{users_with_phones.count}"
    
    users_with_phones.each do |user|
      puts "- #{user.email}: #{user.full_phone_number} (Role: #{user.role})"
    end
    
    sellers_with_phones = User.where(role: 'seller').where.not(phone_number: nil).where.not(phone_number: '')
    puts "\nSellers with phone numbers: #{sellers_with_phones.count}"
    
    sellers_with_inventories = User.joins(:inventories).where(role: 'seller').where.not(phone_number: nil).where.not(phone_number: '').distinct
    puts "Sellers with phone numbers AND inventories: #{sellers_with_inventories.count}"
  end

  desc "Test WhatsApp order template message"
  task test_order_template: :environment do
    phone_number = ENV['TEST_PHONE_NUMBER'] || "+254719459405"
    
    puts "Testing WhatsApp order template message..."
    puts "Phone number: #{phone_number}"
    puts "Template SID: #{ENV['ORDER_PLACED_TEMPLATE_SID']}"
    puts "Messaging Service SID: #{ENV['TWILIO_MESSAGING_SERVICE_SID']}"
    
    begin
      result = WhatsappService.test_order_template_message(
        phone_number,
        3500,
        5,
        "15:45"
      )
      puts "✅ Order template message sent successfully!"
      puts "Message SID: #{result.sid}"
    rescue => e
      puts "❌ Error: #{e.message}"
      puts "Error class: #{e.class}"
    end
  end

  desc "Test order creation with WhatsApp notification"
  task test_order_creation_with_whatsapp: :environment do
    # Find a seller with a phone number and inventory
    seller = User.joins(:inventories).where.not(phone_number: nil).first
    
    if seller.nil?
      puts "No seller with phone number found"
      exit
    end
    
    # Find a buyer (different from seller)
    buyer = User.where.not(id: seller.id).first
    
    if buyer.nil?
      puts "No buyer found"
      exit
    end
    
    # Get seller's inventory
    inventory = seller.inventories.first
    
    if inventory.nil?
      puts "No inventory found for seller"
      exit
    end
    
    puts "Testing order creation with WhatsApp notification..."
    puts "Seller: #{seller.email} (#{seller.full_phone_number})"
    puts "Buyer: #{buyer.email}"
    puts "Inventory: #{inventory.product.name} #{inventory.product.variant}"
    
    # Create a test order
    order = Order.create!(
      buyer: buyer,
      total_amount: 5000,
      status: 'processing'
    )
    
    # Create order items
    OrderItem.create!(
      order: order,
      product: inventory.product,
      inventory: inventory,
      quantity: 2,
      price: inventory.price
    )
    
    if order.persisted?
      puts "✅ Order created successfully (ID: #{order.id})"
      puts "✅ WhatsApp notification should have been sent automatically"
    else
      puts "❌ Failed to create order"
      puts order.errors.full_messages.join(", ")
    end
  end
end
