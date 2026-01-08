class CreateInventories < ActiveRecord::Migration[7.1]
  def change
    create_table :inventories do |t|
      t.references :seller, null: false, foreign_key: { to_table: :users }  # This references the `users` table as sellers
      t.references :product, null: false, foreign_key: true
      t.integer :stock_quantity, null: false, default: 0

      t.timestamps
    end
  end
end
