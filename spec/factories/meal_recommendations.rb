FactoryBot.define do
  factory :meal_recommendation do
    association :meal_plan
    association :food_item
    day_index { 0 }
    meal_type { 'breakfast' }
    recommended_grams { 200 }
  end
end

