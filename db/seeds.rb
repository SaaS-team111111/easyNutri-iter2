# db/seeds.rb
require "json"

puts "Starting to import food nutrition data..."

# USDA FoodData Central JSON 文件路径
json_file_path = Rails.root.join("db", "FoodData_Central_foundation_food_json_2025-04-24.json")

if File.exist?(json_file_path)
  puts "USDA data file found, starting to parse..."
  
  raw_data = JSON.parse(File.read(json_file_path))
  foods = raw_data["FoundationFoods"] || raw_data["foods"] || []
  
  imported_count = 0
  
  foods.each do |food|
    name = food["description"]
    
    # 构建营养素查找映射
    nutrient_map = {}
    if food["foodNutrients"]
      food["foodNutrients"].each do |fn|
        nutrient_name = fn.dig("nutrient", "name")
        amount = fn["amount"]
        nutrient_map[nutrient_name] = amount if nutrient_name && amount
      end
    end
    
    # 提取所需的营养素（每100g）
    calories = nutrient_map["Energy"]
    protein = nutrient_map["Protein"]
    carbs = nutrient_map["Carbohydrate, by difference"]
    fat = nutrient_map["Total lipid (fat)"]
    sodium = nutrient_map["Sodium, Na"]
    
    # 只导入包含所有关键营养信息的食物
    if name && calories && protein && carbs && fat && sodium
      FoodItem.create!(
        name: name,
        calories_per_100g: calories.round,
        protein_per_100g: protein.to_f,
        carbs_per_100g: carbs.to_f,
        fat_per_100g: fat.to_f,
        sodium_mg_per_100g: sodium.round
      )
      imported_count += 1
    end
  end
  
  puts "Successfully imported #{imported_count} food items!"
  
else
  puts "USDA data file not found, creating sample data..."
  puts "To import real data, place FoodData_Central_foundation_food_json_2025-04-24.json in the db/ directory"
  
  # Create sample food data
  sample_foods = [
    {
      name: "Chicken Breast (cooked, skinless)",
      calories_per_100g: 165,
      protein_per_100g: 31.0,
      carbs_per_100g: 0.0,
      fat_per_100g: 3.6,
      sodium_mg_per_100g: 74
    },
    {
      name: "Brown Rice (cooked)",
      calories_per_100g: 111,
      protein_per_100g: 2.6,
      carbs_per_100g: 23.0,
      fat_per_100g: 0.9,
      sodium_mg_per_100g: 5
    },
    {
      name: "Broccoli (cooked)",
      calories_per_100g: 35,
      protein_per_100g: 2.4,
      carbs_per_100g: 7.2,
      fat_per_100g: 0.4,
      sodium_mg_per_100g: 33
    },
    {
      name: "Egg (whole, cooked)",
      calories_per_100g: 155,
      protein_per_100g: 13.0,
      carbs_per_100g: 1.1,
      fat_per_100g: 11.0,
      sodium_mg_per_100g: 124
    },
    {
      name: "Salmon (cooked)",
      calories_per_100g: 206,
      protein_per_100g: 22.0,
      carbs_per_100g: 0.0,
      fat_per_100g: 12.0,
      sodium_mg_per_100g: 59
    },
    {
      name: "Tomato (raw)",
      calories_per_100g: 18,
      protein_per_100g: 0.9,
      carbs_per_100g: 3.9,
      fat_per_100g: 0.2,
      sodium_mg_per_100g: 5
    },
    {
      name: "Oatmeal",
      calories_per_100g: 68,
      protein_per_100g: 2.4,
      carbs_per_100g: 12.0,
      fat_per_100g: 1.4,
      sodium_mg_per_100g: 49
    },
    {
      name: "Banana",
      calories_per_100g: 89,
      protein_per_100g: 1.1,
      carbs_per_100g: 23.0,
      fat_per_100g: 0.3,
      sodium_mg_per_100g: 1
    },
    {
      name: "Beef (lean, cooked)",
      calories_per_100g: 250,
      protein_per_100g: 26.0,
      carbs_per_100g: 0.0,
      fat_per_100g: 16.0,
      sodium_mg_per_100g: 72
    },
    {
      name: "Spinach (cooked)",
      calories_per_100g: 23,
      protein_per_100g: 2.9,
      carbs_per_100g: 3.8,
      fat_per_100g: 0.3,
      sodium_mg_per_100g: 70
    },
    {
      name: "Tofu",
      calories_per_100g: 76,
      protein_per_100g: 8.0,
      carbs_per_100g: 1.9,
      fat_per_100g: 4.8,
      sodium_mg_per_100g: 7
    },
    {
      name: "Carrot (raw)",
      calories_per_100g: 41,
      protein_per_100g: 0.9,
      carbs_per_100g: 10.0,
      fat_per_100g: 0.2,
      sodium_mg_per_100g: 69
    },
    {
      name: "Lentils (cooked)",
      calories_per_100g: 116,
      protein_per_100g: 9.0,
      carbs_per_100g: 20.0,
      fat_per_100g: 0.4,
      sodium_mg_per_100g: 2
    },
    {
      name: "Sweet Potato (baked)",
      calories_per_100g: 90,
      protein_per_100g: 2.0,
      carbs_per_100g: 21.0,
      fat_per_100g: 0.2,
      sodium_mg_per_100g: 36
    },
    {
      name: "Greek Yogurt (non-fat)",
      calories_per_100g: 59,
      protein_per_100g: 10.0,
      carbs_per_100g: 3.6,
      fat_per_100g: 0.4,
      sodium_mg_per_100g: 36
    }
  ]
  
  sample_foods.each do |food_data|
    FoodItem.create!(food_data)
  end
  
  puts "Successfully created #{sample_foods.count} sample food items!"
end

puts "Food data import complete. Database now contains #{FoodItem.count} food items."
