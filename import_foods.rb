require 'json'

data = JSON.parse(File.read(Rails.root.join('db1.json')))
count = 0

data.each do |f|
  FoodItem.create!(
    name: f['name'],
    calories_per_100g: f['calories_per_100g'],
    protein_per_100g: f['protein_per_100g'],
    carbs_per_100g: f['carbs_per_100g'],
    fat_per_100g: f['fat_per_100g'],
    sodium_mg_per_100g: f['sodium_mg_per_100g']
  )
  count += 1
end

puts "Imported #{count} food items, total in DB: #{FoodItem.count}"

