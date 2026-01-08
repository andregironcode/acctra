ActiveAdmin.register Bid do
    actions :all, :except => [:new, :create, :edit, :update]

    controller do
      layout 'admin'
    end

    filter :buyer
    filter :created_at
    filter :quoted_price, label: "Buyer Quoted Price"
    filter :offer_price, label: "Seller Offered Price"

   
  
    index do
      selectable_column
      column :buyer
      column "Seller" do |bid|
        if bid.inventory&.seller
          link_to bid.inventory.seller.full_name, admin_user_path(bid.inventory.seller.id), style: "text-decoration: underline;"
        end
      end
      column :inventory
      column "Status" do |bid|
        bid.status
      end
      column "Buyer Quoted Price" do |bid|
        number_to_currency(bid.quoted_price , precision: 0)
      end  
      column "Seller Offered Price" do |bid|
        number_to_currency(bid.offer_price , precision: 0)
      end   
      actions
    end
  end
  