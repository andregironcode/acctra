if ENV['SENDGRID_API_KEY'].present?
  SendGridActionMailer.configure do |config|
    config.api_key = ENV['SENDGRID_API_KEY']
  end
end
