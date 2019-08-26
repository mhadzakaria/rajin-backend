class AddPasswordFirebaseToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :password_firebase, :string
  end
end
