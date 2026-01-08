class AddApproveToOrder < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :is_approve, :boolean,  default: false
  end
end
