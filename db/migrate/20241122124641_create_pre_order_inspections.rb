class CreatePreOrderInspections < ActiveRecord::Migration[7.1]
  def change
    create_table :pre_order_inspections do |t|
      t.references :order, null: false, foreign_key: true
      t.datetime :inspection_date
      t.string :status
      t.timestamps
    end
  end
end
