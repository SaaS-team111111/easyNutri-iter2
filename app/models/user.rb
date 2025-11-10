class User < ApplicationRecord
  has_many :meal_plans, dependent: :destroy

  validates :name, presence: true
  validates :height_cm, :weight_kg, :age,
    numericality: { only_integer: true, allow_nil: true }
  validates :sex,
    inclusion: { in: ["M", "F"], allow_nil: true }

  # Get the current active meal plan (status = 'active' and not completed)
  def current_meal_plan
    meal_plans.where(status: "active").find { |plan| !plan.completed? }
  end

  # Check if user has an active meal plan
  def has_active_meal_plan?
    current_meal_plan.present?
  end
end
