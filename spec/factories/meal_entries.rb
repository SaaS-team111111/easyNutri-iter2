FactoryBot.define do
  factory :meal_entry do
    association :meal_plan
    association :food_item
    day_index { 0 }
    meal_type { 'breakfast' }
    grams { 200 }
  end
end
