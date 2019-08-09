class AddDurationTypeToJobs < ActiveRecord::Migration[5.2]
  def change
    add_column :jobs, :duration_type, :string
  end
end
