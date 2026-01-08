class AddInventoryToOrderItem < ActiveRecord::Migration[7.1]
  def change
    add_reference :order_items, :inventory, null: false, foreign_key: true
  end
end
