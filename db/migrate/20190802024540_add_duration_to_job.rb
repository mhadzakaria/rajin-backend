class AddDurationToJob < ActiveRecord::Migration[5.2]
  def change
    add_column :jobs, :duration, :integer
  end
end
