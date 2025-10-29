class MealEntry < ApplicationRecord
  belongs_to :meal_plan
  belongs_to :food_item

  validates :day_index,
    numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :meal_type,
    inclusion: { in: ["breakfast", "lunch", "dinner", "snack"] }
  validates :grams,
    numericality: { only_integer: true, greater_than: 0 }
end
