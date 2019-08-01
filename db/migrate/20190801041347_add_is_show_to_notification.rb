class AddIsShowToNotification < ActiveRecord::Migration[5.2]
  def change
    add_column :notifications, :is_show, :boolean, default: true
  end
end
