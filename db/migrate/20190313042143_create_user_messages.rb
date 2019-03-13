class CreateUserMessages < ActiveRecord::Migration[5.2]
  def change
    create_table :user_messages do |t|
      t.integer :job_request_id
      t.text :message_for_accepted_user
      t.text :message_for_rejected_user

      t.timestamps
    end
  end
end
