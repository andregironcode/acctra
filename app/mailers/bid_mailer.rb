class BidMailer < ApplicationMailer
    def new_bid_seller
        @product_name = params[:product_name]
        @amount = params[:amount].to_i
        @quantity = params[:quantity]
        @time = params[:time]
        @recipient_email = params[:email]
        @url =  "https://www.acctra.me//bids"
      
      mail(to: @recipient_email, subject: "New Bid Alert! Someone's Interested in Your Product")
    end


    def new_bid_buyer
        @product_name = params[:product_name]
        @amount = params[:amount].to_i
        @quantity = params[:quantity]
        @time = params[:time]
        @recipient_email = params[:email]
        @url =  "https://www.acctra.me/my-bids"
        
        mail(to: @recipient_email, subject: "New Bid Alert! Someone's Interested in Your Product")
      end
  def new_counter_seller
    @product_name = params[:product_name]
    @amount = params[:amount].to_i
    @quantity = params[:quantity]
    @time = params[:time]
    @recipient_email = params[:email]
    @url =  "https://www.acctra.me/bids"
    
    mail(to: @recipient_email, subject: "New Counter Offer from  buyer")
  end

  def new_counter
    @product_name = params[:product_name]
    @amount = params[:amount].to_i
    @quantity = params[:quantity]
    @time = params[:time]
    @recipient_email = params[:email]
    @url =  "https://www.acctra.me/my-bids"
    
    mail(to: @recipient_email, subject: "New Counter Offer from  seller")
  end
end
  