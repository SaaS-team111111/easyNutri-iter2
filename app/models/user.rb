class User < ApplicationRecord
  has_many :meal_plans, dependent: :destroy

  validates :name, presence: true
  validates :height_cm, :weight_kg, :age,
    numericality: { only_integer: true, allow_nil: true }
  validates :sex,
    inclusion: { in: ["M", "F"], allow_nil: true }
end
