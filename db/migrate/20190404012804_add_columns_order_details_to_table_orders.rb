class AddColumnsOrderDetailsToTableOrders < ActiveRecord::Migration[5.2]
  def change
    change_column :coin_balances, :amount, :decimal
    rename_column :orders, :merchant_id, :payment_id

    add_column :orders, :payment_gateway, :string, index: true
    add_column :orders, :payment_method, :string
    add_column :orders, :amount, :decimal
    add_column :orders, :net_amount, :decimal
  end
end
