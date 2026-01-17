if ENV['SENDGRID_API_KEY'].present?
  ActionMailer::Base.add_delivery_method :sendgrid, Mail::SendGrid,
    api_key: ENV['SENDGRID_API_KEY']
end
