module EasyNutriWorld
  def create_user(name:, height_cm: 170, weight_kg: 70, age: 30, sex: "M")
    User.create!(
      name: name,
      height_cm: height_cm,
      weight_kg: weight_kg,
      age: age,
      sex: sex
    )
  end

  def create_meal_plan(user:, goal:, duration_days:, status: "active")
    MealPlan.create!(
      user: user,
      goal: goal,
      duration_days: duration_days,
      status: status
    )
  end

  def create_food_item(name:, calories_per_100g: 100, protein_per_100g: 10.0, carbs_per_100g: 20.0, fat_per_100g: 5.0, sodium_mg_per_100g: 100)
    FoodItem.create!(
      name: name,
      calories_per_100g: calories_per_100g,
      protein_per_100g: protein_per_100g,
      carbs_per_100g: carbs_per_100g,
      fat_per_100g: fat_per_100g,
      sodium_mg_per_100g: sodium_mg_per_100g
    )
  end

  def create_meal_entry(meal_plan:, food_item:, day_index:, meal_type:, grams:)
    MealEntry.create!(
      meal_plan: meal_plan,
      food_item: food_item,
      day_index: day_index,
      meal_type: meal_type,
      grams: grams
    )
  end
end

World(EasyNutriWorld)

