class CreateNotifications < ActiveRecord::Migration[5.2]
  def change
    create_table :notifications do |t|
      t.integer :user_id
      t.references :notifable, polymorphic: true, index: true
      t.text :message
      t.string :status
      t.float :amount
      t.boolean :reduce_coin

      t.timestamps
    end
  end
end
