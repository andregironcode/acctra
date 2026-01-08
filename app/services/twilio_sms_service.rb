class TwilioSmsService
    def self.send_message(to:, body:)
      client = Twilio::REST::Client.new(TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN)
      message = client.messages.create(
        from: '+18317774413',
        to: to,
        body: body
      )
      message.sid
    rescue Twilio::REST::TwilioError => e
      Rails.logger.error("Failed to send SMS: #{e.message}")
      nil
    end
  end
  