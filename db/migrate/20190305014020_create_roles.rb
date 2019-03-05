class CreateRoles < ActiveRecord::Migration[5.2]
  def change
    create_table :roles do |t|
      t.string :role_name
      t.string :role_code
      t.text :authorities
      t.string :status

      t.timestamps
    end
  end
end
