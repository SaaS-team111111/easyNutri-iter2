FactoryBot.define do
  factory :meal_plan do
    association :user
    goal { 'Weight Loss' }
    duration_days { 7 }
    status { 'active' }
  end
end
