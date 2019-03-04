class CreateSubscriptionPackages < ActiveRecord::Migration[5.2]
  def change
    create_table :subscription_packages do |t|
      t.integer :user_id
      t.date :expired_date
      t.float :amount
      t.string :merchant_id

      t.timestamps
    end
  end
end
