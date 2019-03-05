class CreateSchoolApplies < ActiveRecord::Migration[5.2]
  def change
    create_table :school_applies do |t|
      t.integer :user_id, index: true
      t.integer :menthor_id, index: true
      t.integer :school_partner_id, index: true

      t.timestamps
    end
  end
end
