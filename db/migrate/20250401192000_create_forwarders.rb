class CreateForwarders < ActiveRecord::Migration[7.1]
  def change
    create_table :forwarders do |t|
      t.string :name, null: false
      t.boolean :active, default: true
      t.timestamps
    end
    
    add_index :forwarders, :name, unique: true
    add_index :forwarders, :active
  end
end