class RemoveIndexUniqFromJobRequest < ActiveRecord::Migration[5.2]
  def change
    remove_index :job_requests, column: [:job_id, :user_id], unique: true
    remove_index :job_requests, column: :job_id, unique: true
    remove_index :job_requests, column: :user_id, unique: true

    add_index :job_requests, :job_id
    add_index :job_requests, :user_id
  end
end
