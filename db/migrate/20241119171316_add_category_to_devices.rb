class AddCategoryToDevices < ActiveRecord::Migration[7.1]
  def change
    add_reference :devices, :brand, null: false, foreign_key: true
    add_reference :categories, :brand, null: false, foreign_key: true
    add_reference :categories, :device, null: false, foreign_key: true
  end
end
