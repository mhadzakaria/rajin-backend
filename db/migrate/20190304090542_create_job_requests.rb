class CreateJobRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :job_requests do |t|
      t.integer :user_id
      t.integer :job_id
      t.string :status

      t.timestamps
    end
  end
end
