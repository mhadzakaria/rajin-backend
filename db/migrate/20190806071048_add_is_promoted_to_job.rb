class AddIsPromotedToJob < ActiveRecord::Migration[5.2]
  def change
    add_column :jobs, :is_promoted, :boolean, default: false
  end
end
