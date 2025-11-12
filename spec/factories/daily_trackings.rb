FactoryBot.define do
  factory :daily_tracking do
    association :meal_plan
    day_index { 0 }
    feedback { 'strictly_followed' }
  end
end

