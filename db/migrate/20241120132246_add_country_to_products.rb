class AddCountryToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :country, :string
  end
end
