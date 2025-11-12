FactoryBot.define do
  factory :actual_meal_entry do
    association :meal_plan
    association :food_item
    day_index { 0 }
    meal_type { 'breakfast' }
    grams { 150 }
  end
end

