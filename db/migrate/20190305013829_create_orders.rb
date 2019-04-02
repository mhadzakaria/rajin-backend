class CreateOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :orders do |t|
      t.integer    :user_id, index: true
      t.string     :payment_id, index: true
      t.string     :payment_gateway, index: true
      t.references :orderable, polymorphic: true, index: true
      t.integer    :status
      t.decimal    :amount
      t.string     :payment_method

      t.timestamps
    end
  end
end
