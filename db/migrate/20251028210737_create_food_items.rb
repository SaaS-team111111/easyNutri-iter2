class CreateFoodItems < ActiveRecord::Migration[7.1]
  def change
    create_table :food_items do |t|
      t.string :name
      t.integer :calories_per_100g
      t.float :protein_per_100g
      t.float :carbs_per_100g
      t.float :fat_per_100g
      t.integer :sodium_mg_per_100g

      t.timestamps
    end
  end
end
