class AddModelNumberToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :model_number, :string
  end
end
