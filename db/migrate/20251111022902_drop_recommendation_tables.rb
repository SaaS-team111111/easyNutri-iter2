class DropRecommendationTables < ActiveRecord::Migration[7.1]
  def change
    drop_table :meal_recommendations, if_exists: true
    drop_table :actual_meal_entries, if_exists: true
  end
end
