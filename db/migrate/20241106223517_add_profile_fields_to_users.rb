class AddProfileFieldsToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :contact_info, :string
    add_column :users, :company_name, :string
    add_column :users, :address, :string
    add_column :users, :license_number, :string
    add_column :users, :website, :string
  end
end
