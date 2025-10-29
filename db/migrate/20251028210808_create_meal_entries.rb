class CreateMealEntries < ActiveRecord::Migration[7.1]
  def change
    create_table :meal_entries do |t|
      t.references :meal_plan, null: false, foreign_key: true
      t.references :food_item, null: false, foreign_key: true
      t.integer :day_index
      t.string :meal_type
      t.integer :grams

      t.timestamps
    end
  end
end
