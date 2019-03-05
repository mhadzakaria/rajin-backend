class CreateSubscriptionPackages < ActiveRecord::Migration[5.2]
  def change
    create_table :subscription_packages do |t|
      t.integer :user_id, index: true
      t.date    :expired_date
      t.float   :amount
      t.string  :merchant_id, index: true

      t.timestamps
    end
  end
end
