class AddBrandAndDeviceToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :variant, :string
    add_column :products, :brand_id, :integer
    add_column :products, :device_id, :integer
  end
end
