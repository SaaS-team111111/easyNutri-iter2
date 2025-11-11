class MealPlansController < ApplicationController
  def new
    @meal_plan = MealPlan.new
    @users = User.all
    @show_replace_modal = false
  end

  def create
    user = User.find(meal_plan_params[:user_id])
    
    if params[:replace_existing] == 'true'
      user.meal_plans.where(status: "active").destroy_all
    elsif user.has_active_meal_plan?
      @meal_plan = MealPlan.new(meal_plan_params)
      @users = User.all
      @show_replace_modal = true
      render :new
      return
    end
    
    @meal_plan = MealPlan.new(meal_plan_params)
    @meal_plan.status = "active"
    @meal_plan.current_day = 0

    if @meal_plan.save
      generate_plan_entries(@meal_plan)
      redirect_to root_path(user_id: @meal_plan.user_id), notice: "Meal plan created successfully!"
    else
      @users = User.all
      render :new
    end
  end
  
  def advance_day
    @meal_plan = MealPlan.find(params[:id])
    feedback = params[:feedback]
    
    # Extract actual meals data from params if user used "Eat What I Want"
    actual_meals_data = {}
    %w[breakfast lunch dinner].each do |meal_type|
      if params.dig(:actual_meals, meal_type, :food_item_id).present?
        actual_meals_data[meal_type] = {
          food_item_id: params[:actual_meals][meal_type][:food_item_id],
          grams: params[:actual_meals][meal_type][:grams]
        }
      end
    end
    
    if @meal_plan.advance_day!(feedback, actual_meals_data)
      if @meal_plan.completed?
        @meal_plan.update(status: "completed")
        redirect_to root_path(user_id: @meal_plan.user_id, meal_plan_id: @meal_plan.id, just_completed: true), notice: "Meal plan completed!"
      else
        redirect_to root_path(user_id: @meal_plan.user_id), notice: "Advanced to day #{@meal_plan.current_day + 1}!"
      end
    else
      redirect_to root_path(user_id: @meal_plan.user_id), alert: "Meal plan is already completed!"
    end
  end

  def show
    @meal_plan = MealPlan.find(params[:id])
    @entries_by_day = @meal_plan.meal_entries
      .includes(:food_item)
      .order(:day_index, :meal_type)
      .group_by(&:day_index)
    @actual_meals_by_day = @meal_plan.actual_meal_entries
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
    
    # Select foods based on goal
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
    
    # Generate both meal entries (default recommendations) and meal recommendations (options)
    (0...meal_plan.duration_days).each do |day|
      # Generate default meal entries (for simple view)
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
      
      # Generate meal recommendations (multiple options for "Eat What I Want")
      # 4 options for breakfast
      foods.sample(4).each do |food|
        meal_plan.meal_recommendations.create!(
          food_item: food,
          day_index: day,
          meal_type: "breakfast",
          recommended_grams: rand(150..250)
        )
      end
      
      # 4 options for lunch
      foods.sample(4).each do |food|
        meal_plan.meal_recommendations.create!(
          food_item: food,
          day_index: day,
          meal_type: "lunch",
          recommended_grams: rand(200..350)
        )
      end
      
      # 4 options for dinner
      foods.sample(4).each do |food|
        meal_plan.meal_recommendations.create!(
          food_item: food,
          day_index: day,
          meal_type: "dinner",
          recommended_grams: rand(200..300)
        )
      end
    end
  end
end
