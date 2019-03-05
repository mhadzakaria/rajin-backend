class CreateOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :orders do |t|
      t.integer :user_id
      t.string :merchant_id
      t.references :orderable, polymorphic: true, index: true
      t.string :status

      t.timestamps
    end
  end
end
