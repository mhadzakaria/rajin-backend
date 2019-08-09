class CreateLevelSkills < ActiveRecord::Migration[5.2]
  def change
    create_table :level_skills do |t|
      t.integer :user_id
      t.integer :skill_id
      t.integer :level

      t.timestamps
    end
  end
end
