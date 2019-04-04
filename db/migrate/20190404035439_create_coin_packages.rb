class CreateCoinPackages < ActiveRecord::Migration[5.2]
  def change
    create_table :coin_packages do |t|
      t.decimal :coin
      t.decimal :amount

      t.timestamps
    end
  end
end
