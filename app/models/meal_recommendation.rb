class MealRecommendation < ApplicationRecord
  belongs_to :meal_plan
  belongs_to :food_item

  validates :day_index,
    numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :meal_type,
    inclusion: { in: ["breakfast", "lunch", "dinner", "snack"] }
  validates :recommended_grams,
    numericality: { only_integer: true, greater_than: 0 }

  # Get all recommendations for a specific day and meal
  scope :for_meal, ->(day_index, meal_type) { 
    where(day_index: day_index, meal_type: meal_type).includes(:food_item) 
  }
end
