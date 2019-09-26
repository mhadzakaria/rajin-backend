class AddFirebaseUserId < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :firebase_user_uid, :string
  end
end
