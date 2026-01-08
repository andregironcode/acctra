class AddApprovalStatusToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :approval_status, :string, default: 'pending'
    add_column :users, :suspended, :boolean, default: false
  end
end
