class AddForwarderToBids < ActiveRecord::Migration[7.1]
  def change
    add_column :bids, :forwarder, :string
  end
end
