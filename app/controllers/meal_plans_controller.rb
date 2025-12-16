class MealPlansController < ApplicationController
  def new
    @meal_plan = MealPlan.new
    @users = current_account.users
    @show_replace_modal = false
  end

  def create
    user = current_account.users.find_by(id: meal_plan_params[:user_id])
    unless user
      redirect_to root_path, alert: "Unauthorized user"
      return
    end

    
    if params[:replace_existing] == 'true'
      user.meal_plans.where(status: "active").destroy_all
    elsif user.has_active_meal_plan?
      @meal_plan = user.meal_plans.new(meal_plan_params.except(:user_id))
      @users = current_account.users
      @show_replace_modal = true
      render :new
      return
    end

    @meal_plan = user.meal_plans.new(meal_plan_params.except(:user_id))
    @meal_plan.status = "active"
    @meal_plan.current_day = 0

    if @meal_plan.save
      generate_plan_entries(@meal_plan)
      redirect_to root_path(user_id: @meal_plan.user_id), notice: "Meal plan created successfully!"
    else
      @users = current_account.users
      render :new
    end
  end
  
  def advance_day
    @meal_plan = current_account.meal_plans.find(params[:id])
    feedback = params[:feedback]
    
    # Extract actual meals data from params if user used "Eat What I Want"
    actual_meals_data = {}
    params[:actual_meals]&.each do |meal_type, items|
      next unless items.is_a?(Array)

      meals = items.filter_map do |item|
        next unless item[:food_item_id].present? && item[:grams].present?

        {
          food_item_id: item[:food_item_id],
          grams: item[:grams]
        }
      end

      actual_meals_data[meal_type] = meals if meals.any?
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
    @meal_plan = current_account.meal_plans.find(params[:id])
    meal_order = "CASE meal_type WHEN 'breakfast' THEN 1 WHEN 'lunch' THEN 2 WHEN 'dinner' THEN 3 END"
    @entries_by_day = @meal_plan.meal_entries
      .includes(:food_item)
      .order(Arel.sql("day_index, #{meal_order}"))
      .group_by(&:day_index)
    @actual_meals_by_day = @meal_plan.actual_meal_entries
      .includes(:food_item)
      .order(Arel.sql("day_index, #{meal_order}"))
      .group_by(&:day_index)
    
    # Calculate progress data
    @goal_progress = @meal_plan.goal_progress
    @goal_targets = @meal_plan.goal_targets
    @nutrition_consumed = @meal_plan.actual_nutrition_consumed
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
    
    
    (0...meal_plan.duration_days).each do |day|
      meal_settings = {
        "breakfast" => { range: 150..250 },
        "lunch" => { range: 200..350 },
        "dinner" => { range: 200..300 }
      }

      
      meal_settings.each do |meal_type, config|
        rand(2..3).times do
          MealEntry.create!(
            meal_plan: meal_plan,
            food_item: foods.sample,
            day_index: day,
            meal_type: meal_type,
            grams: rand(config[:range])
          )
        end
      end
      
      
      meal_settings.each do |meal_type, config|
        foods.sample(3).each do |food|
          meal_plan.meal_recommendations.create!(
            food_item: food,
            day_index: day,
            meal_type: meal_type,
            recommended_grams: rand(config[:range])
          )
        end
      end
    end
  end
end
