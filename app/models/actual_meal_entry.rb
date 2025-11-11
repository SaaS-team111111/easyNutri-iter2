class ActualMealEntry < ApplicationRecord
  belongs_to :meal_plan
  belongs_to :food_item

  validates :day_index,
    numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :meal_type,
    inclusion: { in: ["breakfast", "lunch", "dinner", "snack"] }
  validates :grams,
    numericality: { only_integer: true, greater_than: 0 }
  validates :day_index, uniqueness: { 
    scope: [:meal_plan_id, :meal_type],
    message: "Only one actual meal entry per meal type per day" 
  }

  # Get actual meals for a specific day
  scope :for_day, ->(day_index) { 
    where(day_index: day_index).includes(:food_item) 
  }
end
