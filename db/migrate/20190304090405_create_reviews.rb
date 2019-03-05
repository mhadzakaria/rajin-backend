class CreateReviews < ActiveRecord::Migration[5.2]
  def change
    create_table :reviews do |t|
      t.integer :user_id, index: true
      t.integer :sender_id, index: true
      t.integer :job_id, index: true
      t.text    :comment
      t.integer :rate

      t.timestamps
    end
  end
end
