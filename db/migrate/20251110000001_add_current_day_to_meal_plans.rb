class AddCurrentDayToMealPlans < ActiveRecord::Migration[7.1]
  def change
    add_column :meal_plans, :current_day, :integer, default: 0, null: false
  end
end


