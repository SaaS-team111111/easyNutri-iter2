class CreateActualMealEntries < ActiveRecord::Migration[7.1]
  def change
    create_table :actual_meal_entries do |t|
      t.references :meal_plan, null: false, foreign_key: true
      t.integer :day_index, null: false
      t.string :meal_type, null: false
      t.references :food_item, null: false, foreign_key: true
      t.integer :grams, null: false

      t.timestamps
    end
    
    add_index :actual_meal_entries, [:meal_plan_id, :day_index, :meal_type], unique: true
  end
end
