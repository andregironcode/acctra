class CreateOrderProductDetails < ActiveRecord::Migration[7.1]
  def change
    create_table :order_product_details do |t|
      t.references :order, null: false, foreign_key: true
      t.string :sku
      t.string :imei

      t.timestamps
    end
  end
end
