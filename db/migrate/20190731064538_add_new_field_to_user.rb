class AddNewFieldToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :description, :text
    add_column :users, :twitter, :string
    add_column :users, :facebook, :string
    add_column :users, :linkedin, :string
  end
end
