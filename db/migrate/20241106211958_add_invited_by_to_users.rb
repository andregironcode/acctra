class AddInvitedByToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :invited_by, :integer
  end
end
