class CreateJobRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :job_requests do |t|
      t.integer :user_id, index: true
      t.integer :job_id, index: true
      t.string  :status

      t.timestamps
    end

    add_index :job_requests, [:job_id, :user_id], unique: true
  end
end
