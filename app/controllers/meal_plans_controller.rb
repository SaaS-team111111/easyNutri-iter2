class MealPlansController < ApplicationController
  def new
    @meal_plan = MealPlan.new
    @users = User.all
  end

  def create
    @meal_plan = MealPlan.new(meal_plan_params)
    @meal_plan.status = "generated"

    if @meal_plan.save
      generate_plan_entries(@meal_plan)
      redirect_to meal_plan_path(@meal_plan), notice: "Meal plan generated successfully!"
    else
      @users = User.all
      render :new
    end
  end

  def show
    @meal_plan = MealPlan.find(params[:id])
    @entries_by_day = @meal_plan.meal_entries
      .includes(:food_item)
      .order(:day_index, :meal_type)
      .group_by(&:day_index)
  end

  private

  def meal_plan_params
    params.require(:meal_plan).permit(:user_id, :goal, :duration_days)
  end

  def generate_plan_entries(meal_plan)
    all_foods = FoodItem.all.to_a
    
    return if all_foods.empty?
    
    case meal_plan.goal
    when "Low Sodium"
      foods = all_foods.sort_by { |f| f.sodium_mg_per_100g }.take(8)
    when "Weight Loss"
      foods = all_foods.sort_by { |f| f.calories_per_100g.to_f / (f.protein_per_100g + 1) }.take(8)
    when "Muscle Gain"
      foods = all_foods.sort_by { |f| -f.protein_per_100g }.take(8)
    when "Balanced Diet"
      foods = all_foods.sample(8)
    else
      foods = all_foods.sample(8)
    end
    
    foods = all_foods.take(3) if foods.size < 3
    
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
    end
  end
end
