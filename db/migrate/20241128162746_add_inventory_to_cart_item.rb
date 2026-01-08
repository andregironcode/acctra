class AddInventoryToCartItem < ActiveRecord::Migration[7.1]
  def change
    add_reference :cart_items, :inventory, null: false, foreign_key: true

  end
end
