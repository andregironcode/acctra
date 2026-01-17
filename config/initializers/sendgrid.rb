ActionMailer::Base.add_delivery_method :sendgrid, SendGridActionMailer::DeliveryMethod,
  api_key: ENV['SENDGRID_API_KEY']
