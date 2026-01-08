class AddRankToInventories < ActiveRecord::Migration[7.1]
  def change
    add_column :inventories, :rank, :integer
  end
end
