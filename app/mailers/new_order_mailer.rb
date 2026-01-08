class NewOrderMailer < ApplicationMailer
  def new_order
    @order_items = params[:order_items]
    @amount = params[:amount].to_i
    @time = params[:time]
    @recipient_email = params[:email]

    @url =  "https://www.acctra.me/orders-list"

    mail(to: @recipient_email, subject: "New order has been placed")
  end


  def buyer_new_order
    @order_items = params[:order_items]
    @amount = params[:amount].to_i
    @time = params[:time]
    @recipient_email = params[:email]
    @url =  "https://www.acctra.me/my-orders"
    mail(to: @recipient_email, subject: "Your order has been placed")
  end


end
