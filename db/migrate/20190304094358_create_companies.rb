class CreateCompanies < ActiveRecord::Migration[5.2]
  def change
    create_table :companies do |t|
      t.integer :owner_id
      t.string :name
      t.string :status
      t.string :phone_number
      t.text :full_address
      t.string :city
      t.integer :postcode
      t.string :state
      t.string :country
      t.float :latitude
      t.float :longitude

      t.timestamps
    end
  end
end
