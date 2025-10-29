Given(/^there is a user named "([^"]*)" in the database$/) do |name|
  User.create!(
    name: name,
    height_cm: 170,
    weight_kg: 60,
    age: 25,
    sex: 'M'
  )
end

Given(/^there is a food item named "([^"]*)" with (\d+) calories$/) do |name, calories|
  FoodItem.create!(
    name: name,
    calories_per_100g: calories.to_i,
    protein_per_100g: 10.0,
    carbs_per_100g: 20.0,
    fat_per_100g: 5.0,
    sodium_mg_per_100g: 100
  )
end

Given(/^there are multiple food items in the database$/) do
  [
    { name: 'Chicken Breast', calories: 165, protein: 31.0, carbs: 0, fat: 3.6, sodium: 74 },
    { name: 'Apple', calories: 52, protein: 0.3, carbs: 14, fat: 0.2, sodium: 1 },
    { name: 'Rice', calories: 130, protein: 2.7, carbs: 28, fat: 0.3, sodium: 5 },
    { name: 'Salmon', calories: 206, protein: 22, carbs: 0, fat: 13, sodium: 59 },
    { name: 'Broccoli', calories: 34, protein: 2.8, carbs: 7, fat: 0.4, sodium: 33 }
  ].each do |food|
    FoodItem.create!(
      name: food[:name],
      calories_per_100g: food[:calories],
      protein_per_100g: food[:protein],
      carbs_per_100g: food[:carbs],
      fat_per_100g: food[:fat],
      sodium_mg_per_100g: food[:sodium]
    )
  end
end

Given(/^there is a "([^"]*)" meal plan for "([^"]*)", lasting (\d+) days$/) do |goal, user_name, duration|
  user = User.find_by(name: user_name)
  raise "User #{user_name} not found" unless user
  
  MealPlan.create!(
    user: user,
    goal: goal,
    duration_days: duration.to_i,
    status: 'active'
  )
end

When(/^I view the meal plan for "([^"]*)"$/) do |user_name|
  user = User.find_by(name: user_name)
  meal_plan = user.meal_plans.last
  visit meal_plan_path(meal_plan)
end

Then(/^meal entries should be generated$/) do
  meal_plan = MealPlan.last
  expect(meal_plan.meal_entries.count).to be > 0
end

Then(/^the meal plan should be created successfully$/) do
  expect(MealPlan.count).to be > 0
end

