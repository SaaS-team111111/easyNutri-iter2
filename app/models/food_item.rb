class FoodItem < ApplicationRecord
  has_many :meal_entries

  validates :name, presence: true
  validates :calories_per_100g, :protein_per_100g, :carbs_per_100g, :fat_per_100g,
    numericality: true
  validates :sodium_mg_per_100g,
    numericality: { only_integer: true }
end
