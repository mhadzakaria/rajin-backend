class CreateConfigs < ActiveRecord::Migration[5.2]
  def change
    create_table :configs do |t|
      t.integer :user_id, index: true
      t.boolean :email_notif
      t.boolean :receive_notif

      t.timestamps
    end
  end
end
