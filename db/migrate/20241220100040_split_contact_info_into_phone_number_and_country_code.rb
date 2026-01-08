class SplitContactInfoIntoPhoneNumberAndCountryCode < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :country_code, :string
    add_column :users, :phone_number, :string
    remove_column :users, :contact_info, :string
  end
end
