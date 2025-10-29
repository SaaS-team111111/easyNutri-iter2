FactoryBot.define do
  factory :food_item do
    name { 'Chicken Breast' }
    calories_per_100g { 165 }
    protein_per_100g  { 31.0 }
    carbs_per_100g    { 0.0 }
    fat_per_100g      { 3.6 }
    sodium_mg_per_100g { 74 }
  end
end
