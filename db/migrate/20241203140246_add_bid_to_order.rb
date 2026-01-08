class AddBidToOrder < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :was_bid, :boolean,  default: false
  end
end
