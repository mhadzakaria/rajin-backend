class AddFcmRegistrationIdToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :fcm_registration_ids, :string, array: true
  end
end
