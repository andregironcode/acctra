class CreateCarts < ActiveRecord::Migration[7.1]
  def change
    create_table :carts do |t|
      t.references :buyer, null: false, foreign_key: { to_table: :users }
      t.string :status, default: "open"
      t.timestamps
    end
  end
end
