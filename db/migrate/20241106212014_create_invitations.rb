class CreateInvitations < ActiveRecord::Migration[7.1]
  def change
    create_table :invitations do |t|
      t.string :email
      t.string :role
      t.string :token
      t.integer :user_id

      t.timestamps
    end
  end
end
