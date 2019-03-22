class CreateChatSessions < ActiveRecord::Migration[5.2]
  def change
    create_table :chat_sessions do |t|
      t.integer :user_id
      t.integer :user_job_id
      t.integer :job_request_id
      t.integer :status,      default: 0
      t.string :provider_url

      t.timestamps
    end
  end
end
