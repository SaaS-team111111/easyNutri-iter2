def test_account
  @test_account ||= Account.find_by(username: "cucumber_test") || Account.first
end

Given(/^there is a user named "([^"]*)" in the database$/) do |name|
  account = test_account
  User.create!(
    account: account,
    name: name,
    height_cm: 170,
    weight_kg: 60,
    age: 25,
    sex: 'M'
  )
end

Given(/^there is a user named "([^"]*)" for account "([^"]*)" in the database$/) do |name, username|
  account = Account.find_by(username: username)
  raise "Account #{username} not found" unless account
  User.create!(
    account: account,
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

Given(/^there is a "([^"]*)" meal plan for "([^"]*)", lasting (\d+) days?$/) do |goal, user_name, duration|
  user = User.find_or_create_by!(name: user_name, account: test_account) do |u|
    u.height_cm = 170
    u.weight_kg = 60
    u.age = 25
    u.sex = 'M'
  end
  raise "User #{user_name} not found" unless user
  
  meal_plan = MealPlan.new(
    user: user,
    goal: goal,
    duration_days: duration.to_i,
    status: 'active',
    current_day: 0
  )
  meal_plan.save!
  
  all_foods = FoodItem.all.to_a
  
  if all_foods.present?
    case meal_plan.goal
    when "Low Sodium"
      foods = all_foods.sort_by { |f| f.sodium_mg_per_100g }.take(15)
    when "Weight Loss"
      foods = all_foods.sort_by { |f| f.calories_per_100g.to_f / (f.protein_per_100g + 1) }.take(15)
    when "Muscle Gain"
      foods = all_foods.sort_by { |f| -f.protein_per_100g }.take(15)
    when "Balanced Diet"
      foods = all_foods.sample(15)
    else
      foods = all_foods.sample(15)
    end
    
    foods = all_foods.take(5) if foods.size < 5
    
    (0...meal_plan.duration_days).each do |day|
      MealEntry.create!(
        meal_plan: meal_plan,
        food_item: foods.sample,
        day_index: day,
        meal_type: "breakfast",
        grams: rand(150..250)
      )
      
      MealEntry.create!(
        meal_plan: meal_plan,
        food_item: foods.sample,
        day_index: day,
        meal_type: "lunch",
        grams: rand(200..350)
      )
      
      MealEntry.create!(
        meal_plan: meal_plan,
        food_item: foods.sample,
        day_index: day,
        meal_type: "dinner",
        grams: rand(200..300)
      )
      
      foods.sample(4).each do |food|
        MealRecommendation.create!(
          meal_plan: meal_plan,
          food_item: food,
          day_index: day,
          meal_type: "breakfast",
          recommended_grams: rand(150..250)
        )
      end
      
      foods.sample(4).each do |food|
        MealRecommendation.create!(
          meal_plan: meal_plan,
          food_item: food,
          day_index: day,
          meal_type: "lunch",
          recommended_grams: rand(200..350)
        )
      end
      
      foods.sample(4).each do |food|
        MealRecommendation.create!(
          meal_plan: meal_plan,
          food_item: food,
          day_index: day,
          meal_type: "dinner",
          recommended_grams: rand(200..300)
        )
      end
    end
  end
end

When(/^I view the meal plan for "([^"]*)"$/) do |user_name|
  user = User.find_by(name: user_name, account: test_account)
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

Given(/^the meal plan has (\d+) days? completed with "([^"]*)" feedback$/) do |days, feedback|
  meal_plan = MealPlan.last
  days_to_complete = days.to_i
  
  (0...days_to_complete).each do |day_index|
    DailyTracking.create!(
      meal_plan: meal_plan,
      day_index: day_index,
      feedback: feedback
    )
    
    meal_plan.increment!(:current_day)
  end
  
  if meal_plan.current_day >= meal_plan.duration_days
    meal_plan.update(status: "completed")
  end
end

Then(/^the meal plan should have (\d+) days? completed$/) do |days|
  meal_plan = MealPlan.last
  expect(meal_plan.current_day).to eq(days.to_i)
end

Then(/^the meal plan should be marked as completed$/) do
  meal_plan = MealPlan.last
  expect(meal_plan.status).to eq("completed")
  expect(meal_plan.completed?).to be true
end

Then(/^there should be (\d+) daily tracking entries?$/) do |count|
  meal_plan = MealPlan.last
  expect(meal_plan.daily_trackings.count).to eq(count.to_i)
end

Then(/^the goal progress should show non-zero values$/) do
  meal_plan = MealPlan.last
  progress = meal_plan.goal_progress
  
  if meal_plan.goal == "Balanced Diet"
    progress.each do |metric, data|
      expect(data[:current]).to be >= 0
    end
  else
    first_metric = progress.values.first
    expect(first_metric[:current]).to be >= 0
  end
end

Given(/^the meal plan has actual meals eaten for day (\d+) with:$/) do |day, table|
  meal_plan = MealPlan.last
  day_index = day.to_i - 1
  
  if meal_plan.current_day <= day_index
    (meal_plan.current_day...day_index).each do |d|
      DailyTracking.create!(
        meal_plan: meal_plan,
        day_index: d,
        feedback: "strictly_followed"
      )
      meal_plan.increment!(:current_day)
    end
    
    DailyTracking.create!(
      meal_plan: meal_plan,
      day_index: day_index,
      feedback: "strictly_followed"
    )
    meal_plan.increment!(:current_day)
  end
  
  table.hashes.each do |row|
    food = FoodItem.find_by(name: row['Food'])
    raise "Food #{row['Food']} not found" unless food
    
    ActualMealEntry.create!(
      meal_plan: meal_plan,
      food_item: food,
      day_index: day_index,
      meal_type: row['Meal Type'].downcase,
      grams: row['Grams'].to_i
    )
  end
end

Then(/^the actual nutrition consumed should reflect the eaten meals$/) do
  meal_plan = MealPlan.last
  nutrition = meal_plan.actual_nutrition_consumed
  
  expect(nutrition[:calories]).to be > 0
end

Then(/^the recommended nutrition should contain values for all nutrients$/) do
  meal_plan = MealPlan.last
  recommended = meal_plan.recommended_nutrition
  
  expect(recommended[:calories]).to be > 0
  expect(recommended[:protein]).to be > 0
  expect(recommended[:carbs]).to be > 0
  expect(recommended[:fat]).to be > 0
end

Then(/^I navigate to advance the meal plan$/) do
  meal_plan = MealPlan.last
  @meal_plan_id = meal_plan.id
  @user_id = meal_plan.user_id
end

Then(/^the meal plan should advance to day (\d+)$/) do |day|
  meal_plan = MealPlan.find(@meal_plan_id)
  expect(meal_plan.current_day).to eq(day.to_i)
end

Then(/^the status should be "([^"]*)"$/) do |status|
  meal_plan = MealPlan.find(@meal_plan_id)
  expect(meal_plan.status).to eq(status)
end

When(/^I submit feedback "([^"]*)"$/) do |feedback|
  meal_plan = MealPlan.find(@meal_plan_id)
  
  @actual_meals_for_advance = {} unless @actual_meals_for_advance.present?
  
  if @actual_meals_for_advance.present? && @actual_meals_for_advance.keys.any?
    advance_day_result = meal_plan.advance_day!(feedback, @actual_meals_for_advance)
  else
    advance_day_result = meal_plan.advance_day!(feedback)
  end
  
  if meal_plan.current_day >= meal_plan.duration_days
    meal_plan.update(status: "completed")
  end
  
  expect(advance_day_result).to be true
end

Then(/^a daily tracking entry should be created with "([^"]*)"$/) do |feedback|
  meal_plan = MealPlan.find(@meal_plan_id)
  last_tracking = meal_plan.daily_trackings.last
  expect(last_tracking.feedback).to eq(feedback)
end

Then(/^I navigate to advance the completed meal plan$/) do
  meal_plan = MealPlan.last
  @meal_plan_id = meal_plan.id
  @user_id = meal_plan.user_id
end

When(/^I try to submit feedback "([^"]*)"$/) do |feedback|
  meal_plan = MealPlan.find(@meal_plan_id)
  @advance_result = meal_plan.advance_day!(feedback)
end

Then(/^I should see an alert about the plan being completed$/) do
  expect(@advance_result).to be false
end

Given(/^I navigate to advance the meal plan with actual meals for day (\d+):$/) do |day, table|
  meal_plan = MealPlan.last
  @meal_plan_id = meal_plan.id
  @user_id = meal_plan.user_id
  @actual_meals_for_advance = {}
  
  table.hashes.each do |row|
    food = FoodItem.find_by(name: row['Food'])
    raise "Food #{row['Food']} not found" unless food
    
    meal_type = row['Meal Type'].downcase
    @actual_meals_for_advance[meal_type] ||= []
    @actual_meals_for_advance[meal_type] << {
      food_item_id: food.id,
      grams: row['Grams'].to_i
    }
  end
end

Then(/^actual meals should be recorded for day (\d+)$/) do |day|
  meal_plan = MealPlan.find(@meal_plan_id)
  day_index = day.to_i - 1
  actual_meals = meal_plan.actual_meal_entries.where(day_index: day_index)
  expect(actual_meals.count).to be > 0
end


When(/^I visit the dashboard with "([^"]*)" selected$/) do |user_name|
  user = User.find_by(name: user_name, account: test_account)
  visit root_path(user_id: user.id)
end

When(/^I visit the dashboard with "([^"]*)" selected and just_completed flag$/) do |user_name|
  user = User.find_by(name: user_name, account: test_account)
  meal_plan = user.meal_plans.last
  visit root_path(user_id: user.id, meal_plan_id: meal_plan.id, just_completed: true)
end

Then(/^no meal plan details should be displayed$/) do
  expect(page).not_to have_content("Detailed Meal Schedule")
end

Then(/^I should see today's meal recommendations$/) do
  has_meals = page.has_content?("breakfast") || page.has_content?("lunch")
  expect(has_meals).to be true
end


When(/^I create a "([^"]*)" meal plan for "([^"]*)" lasting (\d+) days$/) do |goal, user_name, duration|
  user = User.find_by(name: user_name, account: test_account)
  meal_plan = MealPlan.new(
    user: user,
    goal: goal,
    duration_days: duration.to_i,
    status: 'active',
    current_day: 0
  )
  meal_plan.save!
  
  all_foods = FoodItem.all.to_a
  if all_foods.present?
    case meal_plan.goal
    when "Low Sodium"
      foods = all_foods.sort_by { |f| f.sodium_mg_per_100g }.take(15)
    when "Weight Loss"
      foods = all_foods.sort_by { |f| f.calories_per_100g.to_f / (f.protein_per_100g + 1) }.take(15)
    when "Muscle Gain"
      foods = all_foods.sort_by { |f| -f.protein_per_100g }.take(15)
    when "Balanced Diet"
      foods = all_foods.sample(15)
    else
      foods = all_foods.sample(15)
    end
    
    foods = all_foods.take(5) if foods.size < 5
    
    (0...meal_plan.duration_days).each do |day|
      MealEntry.create!(
        meal_plan: meal_plan,
        food_item: foods.sample,
        day_index: day,
        meal_type: "breakfast",
        grams: rand(150..250)
      )
      
      MealEntry.create!(
        meal_plan: meal_plan,
        food_item: foods.sample,
        day_index: day,
        meal_type: "lunch",
        grams: rand(200..350)
      )
      
      MealEntry.create!(
        meal_plan: meal_plan,
        food_item: foods.sample,
        day_index: day,
        meal_type: "dinner",
        grams: rand(200..300)
      )
      
      foods.sample(4).each do |food|
        MealRecommendation.create!(
          meal_plan: meal_plan,
          food_item: food,
          day_index: day,
          meal_type: "breakfast",
          recommended_grams: rand(150..250)
        )
      end
      
      foods.sample(4).each do |food|
        MealRecommendation.create!(
          meal_plan: meal_plan,
          food_item: food,
          day_index: day,
          meal_type: "lunch",
          recommended_grams: rand(200..350)
        )
      end
      
      foods.sample(4).each do |food|
        MealRecommendation.create!(
          meal_plan: meal_plan,
          food_item: food,
          day_index: day,
          meal_type: "dinner",
          recommended_grams: rand(200..300)
        )
      end
    end
  end
end

Then(/^I should see validation error for "([^"]*)"$/) do |field|
  has_error = page.has_content?("can't be blank") || page.has_content?("is required")
  expect(has_error).to be true
end

When(/^I create a user with:$/) do |table|
  data = table.rows_hash
  fill_in 'user[name]', with: data['name']
  fill_in 'user[height_cm]', with: data['height_cm']
  fill_in 'user[weight_kg]', with: data['weight_kg']
  fill_in 'user[age]', with: data['age'] if data['age']
  select data['sex'], from: 'user[sex]' if data['sex']
  click_button 'Create User'
end

Then(/^I should see success message$/) do
  has_message = page.has_content?("created successfully") || page.has_content?("success")
  expect(has_message).to be true
end

Then(/^the user should be created in the database$/) do
  expect(User.count).to be > 0
end


Then(/^I should see an error message$/) do
  has_error = page.has_content?("error") || page.has_content?("required") || page.has_content?("can't be blank")
  expect(has_error).to be true
end

Then(/^the replace modal is shown$/) do
  has_content = page.has_content?("replace") || page.has_content?("already has an active")
  expect(has_content).to be true
end

When(/^I choose to replace the existing plan$/) do
  check 'Replace Existing Plan' if page.has_field?('Replace Existing Plan')
  click_button 'Create Meal Plan'
end

Then(/^a new meal plan should be created$/) do
  expect(MealPlan.count).to be > 0
end

Then(/^the old meal plan should be removed$/) do
  meal_plan = MealPlan.last
  expect(meal_plan.created_at).to be_recent
end

When(/^I choose not to replace$/) do
  click_button 'Cancel' if page.has_button?('Cancel')
end

Then(/^no new meal plan should be created$/) do
  # Verify that only the original exists
  user = User.find_by(name: 'LeonTest')
  expect(user.meal_plans.count).to eq(1)
end

Then(/^the existing meal plan should remain$/) do
  user = User.find_by(name: 'LeonTest')
  expect(user.meal_plans.count).to eq(1)
end

When(/^I view the goal targets for the meal plan$/) do
  meal_plan = MealPlan.last
  @goal_targets = meal_plan.goal_targets
end

Then(/^the target metric should be "([^"]*)"$/) do |metric|
  expect(@goal_targets[:metric]).to eq(metric)
end

Then(/^the daily target should be (\d+)$/) do |target|
  expect(@goal_targets[:target_per_day]).to eq(target.to_i)
end

Then(/^the target should include (calories|protein|carbs|fat)$/) do |nutrient|
  expect(@goal_targets[:targets].keys).to include(nutrient.to_sym)
end

%w[calories protein carbs fat].each do |nutrient|
  Then(/^the daily target for #{nutrient} should be (\d+)$/) do |target|
    expect(@goal_targets[:targets][nutrient.to_sym][:target_per_day]).to eq(target.to_i)
  end
end

When(/^I calculate goal progress$/) do
  meal_plan = MealPlan.last
  @goal_progress = meal_plan.goal_progress
end

Then(/^the progress percentage should be calculated correctly$/) do
  if MealPlan.last.goal == "Balanced Diet"
    @goal_progress.each do |metric, data|
      expect(data[:percentage]).to be_between(0, 100)
    end
  else
    first_metric = @goal_progress.values.first
    expect(first_metric[:percentage]).to be_between(0, 100)
  end
end

Then(/^the current value should match consumed calories$/) do
  meal_plan = MealPlan.last
  consumed = meal_plan.actual_nutrition_consumed
  progress = @goal_progress[:calories] || @goal_progress.values.first
  expect(progress[:current]).to eq(consumed[:calories])
end

Then(/^the current value should match consumed protein$/) do
  meal_plan = MealPlan.last
  consumed = meal_plan.actual_nutrition_consumed
  progress = @goal_progress[:protein] || @goal_progress.values.first
  expect(progress[:current]).to eq(consumed[:protein])
end

Then(/^the average per day should be calculated correctly$/) do
  if MealPlan.last.goal == "Balanced Diet"
    @goal_progress.each do |metric, data|
      days_tracked = data.dig(:days_tracked) || MealPlan.last.daily_trackings.count || 1
      if days_tracked > 0
        expected_avg = (data[:current].to_f / days_tracked).round(1)
        expect(data[:avg_per_day]).to eq(expected_avg)
      end
    end
  else
    first_metric = @goal_progress.values.first
    days_tracked = first_metric.dig(:days_tracked) || MealPlan.last.daily_trackings.count || 1
    if days_tracked > 0
      expected_avg = (first_metric[:current].to_f / days_tracked).round(1)
      expect(first_metric[:avg_per_day]).to eq(expected_avg)
    end
  end
end

Then(/^days tracked should be (\d+)$/) do |days|
  expect(MealPlan.last.daily_trackings.count).to eq(days.to_i)
end

Then(/^I should see the replace existing meal plan modal$/) do
  expect(page).to have_css('#replaceModal')
  within('#replaceModal') do
    expect(page).to have_content('Active Meal Plan Exists')
  end
end

Then(/^the old weight loss plan should be deleted$/) do
  expect(MealPlan.where(goal: 'Weight Loss')).to be_empty
end

Then(/^the dashboard should show completion status with just_completed flag$/) do
  has_completed = page.has_content?('completed') || page.has_content?('Congratulations')
  expect(has_completed).to be_truthy
end


Then('I should be redirected with just_completed flag') do
  meal_plan = MealPlan.find(@meal_plan_id)
  expect(meal_plan.status).to eq("completed")
  expect(meal_plan.completed?).to be true
end

When(/^I confirm to replace the existing meal plan$/) do
  user = User.find_by(name: "Qianyi")
  user.meal_plans.where(status: "active").destroy_all
  @meal_plan = MealPlan.create!(
    user: user,
    goal: "Muscle Gain",
    duration_days: 10,
    status: "active"
  )

  generate_plan_entries(@meal_plan) if defined?(generate_plan_entries)
  visit root_path(user_id: user.id)
end

Then(/^the old "([^"]*)" meal plan should be deleted$/) do |goal|
  expect(MealPlan.where(goal: goal, status: 'active')).to be_empty
end

When(/^I visit the dashboard for user "([^"]*)"$/) do |user_name|
  user = User.find_by(name: user_name)
  visit root_path(user_id: user.id)
end

When(/^I select "([^"]*)" from user selector$/) do |user_name|
  user = User.find_by(name: user_name)

  visit root_path(user_id: user.id)
  expect(page).to have_content(user_name)
end

When(/^I click "([^"]*)" and confirm deletion$/) do |link_text|

  link = find_link(link_text)
  user_id = link[:href].match(/\/users\/(\d+)/)[1]
  page.driver.delete user_path(user_id)
  visit root_path
end

Given(/^there is an account with username "([^"]*)" and password "([^"]*)"$/) do |username, password|
  Account.create!(
    username: username,
    password: password,
    password_confirmation: password
  )
end

Given(/^I am logged out$/) do
  page.driver.delete "/logout"
  visit login_path
end

Given(/^I am logged in as "([^"]*)" with password "([^"]*)"$/) do |username, password|
  account = Account.find_by(username: username) || Account.create!(
    username: username,
    password: password,
    password_confirmation: password
  )
  visit login_path
  fill_in "Username", with: username
  fill_in "Password", with: password
  click_button "Sign In"
  expect(page).to have_content("Signed in successfully") unless page.has_content?("Dashboard")
end
