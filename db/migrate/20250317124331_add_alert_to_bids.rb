class AddAlertToBids < ActiveRecord::Migration[7.1]
  def change
    add_column :bids, :alert, :boolean , default: nil
  end
end
