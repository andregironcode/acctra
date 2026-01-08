class AddForwarderToOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :forwarder, :string
  end
end
