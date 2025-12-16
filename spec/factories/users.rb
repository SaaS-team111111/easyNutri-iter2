FactoryBot.define do
  factory :user do
    association :account
    name { 'Test User' }
    height_cm { 170 }
    weight_kg { 65 }
    age { 25 }
    sex { 'M' }
  end
end
