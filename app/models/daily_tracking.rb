class DailyTracking < ApplicationRecord
  belongs_to :meal_plan

  FEEDBACKS = ["strictly_followed", "less_healthy", "more_healthy"]

  validates :day_index,
    numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :feedback, presence: true, inclusion: { in: FEEDBACKS }
  validates :day_index, uniqueness: { scope: :meal_plan_id }
end
