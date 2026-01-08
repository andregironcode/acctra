class AddFieldsToBid < ActiveRecord::Migration[7.1]
  def change
    add_reference :bids, :inventory, null: false, foreign_key: true
    add_column :bids, :quoted_price, :decimal
    add_column :bids, :accepted_price, :decimal
    add_column :bids, :quantity, :integer
    remove_reference :bids, :product, foreign_key: true

  end
end
