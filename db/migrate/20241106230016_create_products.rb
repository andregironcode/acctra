class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products do |t|
      t.string :name
      t.string :sku
      t.text :description
      t.decimal :price
      t.string :category
      t.references :seller, null: false, foreign_key: { to_table: :users }  # This references the `users` table

      t.timestamps
    end
  end
end
