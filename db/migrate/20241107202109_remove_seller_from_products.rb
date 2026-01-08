class RemoveSellerFromProducts < ActiveRecord::Migration[7.1]
  def change
    remove_foreign_key :products, column: :seller_id
    remove_column :products, :seller_id
  end
end
