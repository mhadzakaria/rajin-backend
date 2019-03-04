class CreateReviews < ActiveRecord::Migration[5.2]
  def change
    create_table :reviews do |t|
      t.integer :user_id
      t.integer :sender_id
      t.integer :job_id
      t.text :comment
      t.integer :rate

      t.timestamps
    end
  end
end
