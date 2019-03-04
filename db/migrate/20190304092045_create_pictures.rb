class CreatePictures < ActiveRecord::Migration[5.2]
  def change
    create_table :pictures do |t|
      t.integer :user_id
      t.references :pictureable, polymorphic: true, index: true
      t.string :file_url
      t.string :file_type

      t.timestamps
    end
  end
end
