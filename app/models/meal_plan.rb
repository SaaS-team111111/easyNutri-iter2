class MealPlan < ApplicationRecord
  belongs_to :user
  has_many :meal_entries, dependent: :destroy

  GOALS = ["Weight Loss", "Muscle Gain", "Low Sodium", "Balanced Diet"]

  validates :goal, presence: true, inclusion: { in: GOALS }
  validates :duration_days,
    presence: true,
    numericality: { only_integer: true, greater_than: 0 }
  validates :status, presence: true
end
