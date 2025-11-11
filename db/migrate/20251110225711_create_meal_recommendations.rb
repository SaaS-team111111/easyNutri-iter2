class CreateMealRecommendations < ActiveRecord::Migration[7.1]
  def change
    create_table :meal_recommendations do |t|
      t.references :meal_plan, null: false, foreign_key: true
      t.integer :day_index, null: false
      t.string :meal_type, null: false
      t.references :food_item, null: false, foreign_key: true
      t.integer :recommended_grams, null: false

      t.timestamps
    end
    
    add_index :meal_recommendations, [:meal_plan_id, :day_index, :meal_type]
  end
end
