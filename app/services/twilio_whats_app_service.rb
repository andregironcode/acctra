class TwilioWhatsAppService
  def self.send_message(to:, content_sid:, content_variables: '')
    client = Twilio::REST::Client.new(TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN)
    message = client.messages.create(
      from: TWILIO_WHATSAPP_NUMBER,
      to: "whatsapp:#{to}",
      content_sid: content_sid,
      content_variables: content_variables.to_json 
      )
    message.sid
  rescue Twilio::REST::TwilioError => e
    Rails.logger.error("Failed to send WhatsApp message: #{e.message}")
    nil
  end
end