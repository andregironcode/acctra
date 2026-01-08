class CreateBids < ActiveRecord::Migration[7.1]
  def change
    create_table :bids do |t|
      t.references :buyer, null: false, foreign_key: { to_table: :users }
      t.references :product, null: false, foreign_key: true
      t.decimal :offer_price, precision: 10, scale: 2
      t.string :status, default: "pending"
      t.timestamps
    end
  end
end
