class CreateJobs < ActiveRecord::Migration[5.2]
  def change
    create_table :jobs do |t|
      t.string   :title
      t.text     :description
      t.text     :payment_term
      t.integer  :amount
      t.string   :payment_type
      t.text     :full_address
      t.string   :city
      t.string   :postcode
      t.string   :state
      t.string   :country
      t.datetime :start_date
      t.datetime :end_date
      t.float    :latitude
      t.float    :longitude
      t.string   :status
      t.integer  :job_category_id, index: true
      t.integer  :user_id, index: true
      t.text  :skill_ids

      t.timestamps
    end
  end
end
