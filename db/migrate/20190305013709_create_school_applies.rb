class CreateSchoolApplies < ActiveRecord::Migration[5.2]
  def change
    create_table :school_applies do |t|
      t.integer :user_id
      t.integer :menthor_id
      t.integer :school_partner_id

      t.timestamps
    end
  end
end
