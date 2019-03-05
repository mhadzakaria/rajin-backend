class CreateCoinBalances < ActiveRecord::Migration[5.2]
  def change
    create_table :coin_balances do |t|
      t.integer    :user_id, index: true
      t.integer    :amount
      t.references :coinable, polymorphic: true, index: true

      t.timestamps
    end
  end
end
