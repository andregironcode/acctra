class WhatsappController < ApplicationController
  def test_message
    begin
      # Get parameters from request
      to_number = params[:to] || '+1234567890'  # Default test number
      message_body = params[:message] || 'Hello from Acctra! This is a test message from our WhatsApp integration.'

      # Send WhatsApp message using service
      message = WhatsappService.send_message(
        to: to_number,
        message: message_body
      )

      render json: {
        success: true,
        message: 'WhatsApp message sent successfully!',
        message_sid: message.sid,
        to: to_number,
        from: ENV['TWILIO_WHATSAPP_NUMBER'],
        body: message_body,
        status: message.status
      }, status: 200

    rescue WhatsappService::ConfigurationError => e
      render json: {
        success: false,
        error: 'Configuration Error',
        message: 'WhatsApp service is not properly configured. Please check your Twilio credentials.'
      }, status: 500

    rescue WhatsappService::TwilioError => e
      render json: {
        success: false,
        error: 'Twilio Error',
        message: e.message,
        code: e.code
      }, status: 400

    rescue => e
      render json: {
        success: false,
        error: 'General Error',
        message: e.message
      }, status: 500
    end
  end

  def test_form
    # Simple form to test WhatsApp messages
  end

  def send_order_notification
    begin
      order_id = params[:order_id]
      phone_number = params[:phone_number]
      customer_name = params[:customer_name]
      
      if order_id.blank? || phone_number.blank?
        render json: {
          success: false,
          error: 'Missing parameters',
          message: 'order_id and phone_number are required'
        }, status: 400
        return
      end

      message = WhatsappService.send_order_notification(
        order_id: order_id,
        phone_number: phone_number,
        customer_name: customer_name
      )

      render json: {
        success: true,
        message: 'Order notification sent successfully!',
        message_sid: message.sid,
        order_id: order_id
      }, status: 200

    rescue => e
      render json: {
        success: false,
        error: e.message
      }, status: 500
    end
  end

  def send_bid_notification
    begin
      bid_amount = params[:bid_amount]
      product_name = params[:product_name]
      phone_number = params[:phone_number]
      buyer_name = params[:buyer_name]
      
      if bid_amount.blank? || product_name.blank? || phone_number.blank?
        render json: {
          success: false,
          error: 'Missing parameters',
          message: 'bid_amount, product_name, and phone_number are required'
        }, status: 400
        return
      end

      message = WhatsappService.send_bid_notification(
        bid_amount: bid_amount,
        product_name: product_name,
        phone_number: phone_number,
        buyer_name: buyer_name
      )

      render json: {
        success: true,
        message: 'Bid notification sent successfully!',
        message_sid: message.sid
      }, status: 200

    rescue => e
      render json: {
        success: false,
        error: e.message
      }, status: 500
    end
  end

  def test_kenyan_number
    begin
      message = WhatsappService.test_kenyan_number

      render json: {
        success: true,
        message: 'Test message sent to Kenyan number successfully!',
        message_sid: message.sid,
        to: '+254719459405',
        status: message.status
      }, status: 200

    rescue WhatsappService::ConfigurationError => e
      render json: {
        success: false,
        error: 'Configuration Error',
        message: 'WhatsApp service is not properly configured. Please check your Twilio credentials.'
      }, status: 500

    rescue WhatsappService::TwilioError => e
      render json: {
        success: false,
        error: 'Twilio Error',
        message: e.message,
        code: e.code
      }, status: 400

    rescue => e
      render json: {
        success: false,
        error: 'General Error',
        message: e.message
      }, status: 500
    end
  end

  def test_templated_message
    begin
      phone_number = params[:phone_number] || '+254719459405'
      
      # Custom parameters for the template
      template_params = {
        product: params[:product] || "Samsung Galaxy S21",
        amount: params[:amount] || "500",
        quantity: params[:quantity] || "1",
        time: params[:time] || "2 days"
      }

      message = WhatsappService.send_templated_message(
        to: phone_number,
        params: template_params
      )

      render json: {
        success: true,
        message: 'Templated WhatsApp message sent successfully!',
        message_sid: message.sid,
        to: phone_number,
        status: message.status,
        template_params: template_params
      }, status: 200

    rescue WhatsappService::ConfigurationError => e
      render json: {
        success: false,
        error: 'Configuration Error',
        message: 'WhatsApp template service is not properly configured. Please check your Twilio template credentials.'
      }, status: 500

    rescue WhatsappService::TwilioError => e
      error_details = case e.code.to_i
      when 63027
        'Template does not exist for the specified language/locale. Please check your Twilio Console to ensure the template is approved and available for your locale.'
      when 63016
        'WhatsApp is not enabled for this number. Please enable WhatsApp in your Twilio Console or use the WhatsApp Sandbox.'
      when 63034
        'Template parameter validation failed. Please check the template parameters match your approved template.'
      else
        e.message
      end

      render json: {
        success: false,
        error: 'Twilio Template Error',
        message: error_details,
        code: e.code,
        suggested_action: get_template_error_suggestion(e.code.to_i)
      }, status: 400

    rescue => e
      render json: {
        success: false,
        error: 'General Error',
        message: e.message
      }, status: 500
    end
  end

  def configuration_status
    render json: WhatsappService.configuration_status
  end

  def test_bid_notification
    @sellers = User.joins(:inventories).where.not(phone_number: nil).limit(10)
  end

  def send_test_bid_notification
    seller = User.find(params[:seller_id])
    inventory = seller.inventories.first
    
    if inventory.nil?
      flash[:error] = "No inventory found for this seller"
      redirect_to whatsapp_test_bid_notification_path
      return
    end
    
    product_name = "#{inventory.product.name} #{inventory.product.variant}"
    
    success = WhatsappService.send_new_bid_notification(
      seller: seller,
      product_name: product_name,
      quantity: params[:quantity] || 1,
      amount: params[:amount] || 1000,
      time: Time.current.strftime("%H:%M")
    )
    
    if success
      flash[:notice] = "WhatsApp bid notification sent successfully to #{seller.email}"
    else
      flash[:error] = "Failed to send WhatsApp bid notification"
    end
    
    redirect_to whatsapp_test_bid_notification_path
  end

  def test_bid_template
    phone_number = params[:phone_number]
    product_name = params[:product_name] || "iPhone 14 Pro - 256GB"
    amount = params[:amount] || 1500
    quantity = params[:quantity] || 1
    time = params[:time] || "24 hours"
    
    begin
      result = WhatsappService.test_bid_template_message(
        phone_number,
        product_name,
        amount,
        quantity,
        time
      )
      
      flash[:notice] = "Bid template message sent successfully! SID: #{result.sid}"
    rescue => e
      flash[:error] = "Error sending bid template message: #{e.message}"
    end
    
    redirect_to whatsapp_test_path
  end

  def test_order_template
    phone_number = params[:phone_number]
    order_amount = params[:order_amount] || 2500
    total_items = params[:total_items] || 3
    time = params[:time] || Time.current.strftime("%H:%M")
    
    begin
      result = WhatsappService.test_order_template_message(
        phone_number,
        order_amount,
        total_items,
        time
      )
      
      flash[:notice] = "Order template message sent successfully! SID: #{result.sid}"
    rescue => e
      flash[:error] = "Error sending order template message: #{e.message}"
    end
    
    redirect_to whatsapp_test_path
  end

  private

  def validate_phone_number(phone)
    # Basic phone number validation
    phone.match?(/^\+[1-9]\d{1,14}$/)
  end

  def get_template_error_suggestion(error_code)
    case error_code
    when 63027
      "1. Check Twilio Console → Messaging → Templates to ensure your template is approved\n2. Verify the template supports your target language/locale\n3. Consider using a basic text message instead of templates for testing"
    when 63016
      "1. Enable WhatsApp Business API in Twilio Console\n2. Join WhatsApp Sandbox for testing\n3. Verify your sender number is WhatsApp-enabled"
    when 63034
      "1. Check template parameter names match exactly\n2. Ensure all required parameters are provided\n3. Verify parameter data types (string, number, etc.)"
    else
      "Check Twilio documentation for error code #{error_code}"
    end
  end
end
