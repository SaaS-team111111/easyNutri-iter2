class MealPlan < ApplicationRecord
  belongs_to :user
  has_many :meal_entries, dependent: :destroy
  has_many :daily_trackings, dependent: :destroy
  has_many :meal_recommendations, dependent: :destroy
  has_many :actual_meal_entries, dependent: :destroy

  GOALS = ["Weight Loss", "Muscle Gain", "Low Sodium", "Balanced Diet"]

  validates :goal, presence: true, inclusion: { in: GOALS }
  validates :duration_days,
    presence: true,
    numericality: { only_integer: true, greater_than: 0 }
  validates :status, presence: true
  validates :current_day,
    numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :user_can_only_have_one_active_plan, on: :create

  # Get meals for a specific day (old system)
  def meals_for_day(day_index)
    meal_entries.where(day_index: day_index).includes(:food_item).order(:meal_type)
  end

  # Get today's meals (old system)
  def today_meals
    meals_for_day(current_day)
  end

  # Get today's recommendations grouped by meal type
  def today_recommendations
    meal_recommendations.where(day_index: current_day).includes(:food_item).group_by(&:meal_type)
  end

  # Get actual meals for today
  def today_actual_meals
    actual_meal_entries.where(day_index: current_day).includes(:food_item).group_by(&:meal_type)
  end

  # Check if meal plan is completed
  def completed?
    current_day >= duration_days
  end

  # Goal targets based on meal plan type
  def goal_targets
    case goal
    when "Low Sodium"
      {
        metric: "sodium",
        target_per_day: 1500,  # mg per day (recommended limit)
        unit: "mg",
        description: "Daily Sodium Intake"
      }
    when "Weight Loss"
      {
        metric: "calories",
        target_per_day: 1800,  # calories per day
        unit: "kcal",
        description: "Daily Calorie Intake"
      }
    when "Muscle Gain"
      {
        metric: "protein",
        target_per_day: 150,  # grams per day
        unit: "g",
        description: "Daily Protein Intake"
      }
    when "Balanced Diet"
      {
        metric: "balanced",
        targets: {
          calories: { target_per_day: 2000, unit: "kcal" },
          protein: { target_per_day: 80, unit: "g" },
          carbs: { target_per_day: 250, unit: "g" },
          fat: { target_per_day: 65, unit: "g" }
        },
        description: "Balanced Nutrition"
      }
    end
  end

  # Calculate actual consumed nutrition from all past days
  # Uses actual_meal_entries if user used "Eat What I Want", otherwise uses meal_entries (default recommendation)
  def actual_nutrition_consumed
    total = {
      calories: 0,
      protein: 0,
      carbs: 0,
      fat: 0,
      sodium: 0,
      days_tracked: 0
    }
    
    # For each past day (before current_day)
    (0...current_day).each do |day_index|
      # Check if user has actual meal entries for this day
      actual_entries_for_day = actual_meal_entries.where(day_index: day_index).includes(:food_item)
      
      if actual_entries_for_day.any?
        # User used "Eat What I Want" - use actual entries
        actual_entries_for_day.each do |entry|
          multiplier = entry.grams / 100.0
          total[:calories] += (entry.food_item.calories_per_100g * multiplier).round
          total[:protein] += (entry.food_item.protein_per_100g * multiplier).round(1)
          total[:carbs] += (entry.food_item.carbs_per_100g * multiplier).round(1)
          total[:fat] += (entry.food_item.fat_per_100g * multiplier).round(1)
          total[:sodium] += (entry.food_item.sodium_mg_per_100g * multiplier).round
        end
      else
        # User didn't use "Eat What I Want" - assume they followed the default recommendation
        default_entries_for_day = meal_entries.where(day_index: day_index).includes(:food_item)
        default_entries_for_day.each do |entry|
          multiplier = entry.grams / 100.0
          total[:calories] += (entry.food_item.calories_per_100g * multiplier).round
          total[:protein] += (entry.food_item.protein_per_100g * multiplier).round(1)
          total[:carbs] += (entry.food_item.carbs_per_100g * multiplier).round(1)
          total[:fat] += (entry.food_item.fat_per_100g * multiplier).round(1)
          total[:sodium] += (entry.food_item.sodium_mg_per_100g * multiplier).round
        end
      end
      
      total[:days_tracked] += 1
    end
    
    total
  end

  # Calculate recommended nutrition from meal_entries (default recommendations)
  def recommended_nutrition
    entries = meal_entries.where("day_index < ?", duration_days).includes(:food_item)
    
    total = {
      calories: 0,
      protein: 0,
      carbs: 0,
      fat: 0,
      sodium: 0
    }
    
    entries.each do |entry|
      multiplier = entry.grams / 100.0
      total[:calories] += (entry.food_item.calories_per_100g * multiplier).round
      total[:protein] += (entry.food_item.protein_per_100g * multiplier).round(1)
      total[:carbs] += (entry.food_item.carbs_per_100g * multiplier).round(1)
      total[:fat] += (entry.food_item.fat_per_100g * multiplier).round(1)
      total[:sodium] += (entry.food_item.sodium_mg_per_100g * multiplier).round
    end
    
    total
  end

  # Calculate progress for the current goal
  def goal_progress
    targets = goal_targets
    consumed = actual_nutrition_consumed
    days_tracked = consumed[:days_tracked]
    days_tracked = 1 if days_tracked == 0  # Avoid division by zero
    
    if goal == "Balanced Diet"
      # For balanced diet, calculate progress for each metric
      progress = {}
      targets[:targets].each do |metric, target_info|
        target_total = target_info[:target_per_day] * duration_days
        actual_total = consumed[metric]
        progress[metric] = {
          current: actual_total,
          target: target_total,
          percentage: [(actual_total.to_f / target_total * 100).round(1), 100].min,
          unit: target_info[:unit],
          avg_per_day: (actual_total.to_f / days_tracked).round(1),
          target_per_day: target_info[:target_per_day]
        }
      end
      progress
    else
      # For single metric goals
      metric = targets[:metric].to_sym
      target_total = targets[:target_per_day] * duration_days
      actual_total = consumed[metric]
      
      {
        metric => {
          current: actual_total,
          target: target_total,
          percentage: [(actual_total.to_f / target_total * 100).round(1), 100].min,
          unit: targets[:unit],
          avg_per_day: (actual_total.to_f / days_tracked).round(1),
          target_per_day: targets[:target_per_day],
          description: targets[:description]
        }
      }
    end
  end

  # Advance to next day with feedback and actual meals
  def advance_day!(feedback, actual_meals_data = {})
    return false if completed?
    
    transaction do
      # Save actual meals if provided
      if actual_meals_data.present?
        %w[breakfast lunch dinner].each do |meal_type|
          next unless actual_meals_data[meal_type].present?
          
          food_id = actual_meals_data[meal_type][:food_item_id]
          grams = actual_meals_data[meal_type][:grams]
          
          next unless food_id.present? && grams.present?
          
          actual_meal_entries.create!(
            day_index: current_day,
            meal_type: meal_type,
            food_item_id: food_id,
            grams: grams
          )
        end
      end
      
      daily_trackings.create!(
        day_index: current_day,
        feedback: feedback
      )
      
      increment!(:current_day)
      
      # Regenerate future meals based on actual consumption
      regenerate_recommendations_from(current_day) if current_day < duration_days
    end
    
    true
  end

  private
  
  def user_can_only_have_one_active_plan
    if status == "active" && user && user.meal_plans.where(status: "active").where.not(id: id).exists?
      errors.add(:base, "User already has an active meal plan")
    end
  end

  def regenerate_recommendations_from(start_day)
    # Delete future recommendations and meal entries
    meal_recommendations.where("day_index >= ?", start_day).delete_all
    meal_entries.where("day_index >= ?", start_day).delete_all
    
    # Get actual eating history
    actual_eaten_foods = actual_meal_entries
      .where("day_index < ?", start_day)
      .includes(:food_item)
      .group_by { |entry| entry.food_item.id }
    
    # Get feedback history
    feedback_counts = daily_trackings.group(:feedback).count
    
    # Adjust food selection based on feedback and actual consumption
    all_foods = FoodItem.all.to_a
    return if all_foods.empty?
    
    # Calculate adjustment factor based on feedback
    more_healthy_count = feedback_counts["more_healthy"] || 0
    less_healthy_count = feedback_counts["less_healthy"] || 0
    
    foods = select_foods_for_goal_based_on_history(
      all_foods, 
      actual_eaten_foods,
      more_healthy_count, 
      less_healthy_count
    )
    
    # Generate recommendations for remaining days (both default and options)
    (start_day...duration_days).each do |day|
      generate_day_meals(day, foods)
      generate_day_recommendations(day, foods)
    end
  end

  def select_foods_for_goal_based_on_history(all_foods, actual_eaten_foods, more_healthy_count, less_healthy_count)
    # Adjust selection strictness based on user feedback
    # If user ate less healthy → increase strictness (be more strict)
    # If user ate more healthy → decrease strictness (can be more relaxed)
    strictness = 1.0 + (less_healthy_count * 0.1) - (more_healthy_count * 0.1)
    strictness = [0.5, [strictness, 2.0].min].max  # Clamp between 0.5 and 2.0
    
    count = [12, (12 * strictness).to_i].max  # Increased to provide more options
    
    # Get frequently eaten foods
    frequently_eaten_ids = actual_eaten_foods.select { |_id, entries| entries.size >= 2 }.keys
    frequently_eaten = all_foods.select { |f| frequently_eaten_ids.include?(f.id) }
    
    # Select foods based on goal
    goal_foods = case goal
    when "Low Sodium"
      all_foods.sort_by { |f| f.sodium_mg_per_100g }.take(count * 2)
    when "Weight Loss"
      all_foods.sort_by { |f| f.calories_per_100g.to_f / (f.protein_per_100g + 1) }.take(count * 2)
    when "Muscle Gain"
      all_foods.sort_by { |f| -f.protein_per_100g }.take(count * 2)
    when "Balanced Diet"
      all_foods.shuffle
    else
      all_foods.shuffle
    end
    
    # Mix frequently eaten foods with goal-based foods
    result = (frequently_eaten + goal_foods).uniq.take(count)
    result = goal_foods.take(count) if result.size < 5
    result
  end

  def generate_day_meals(day, foods)
    # Generate default single recommendation for each meal
    # Calculate recommended grams based on goal progress
    targets = goal_targets
    consumed = actual_nutrition_consumed
    
    # Calculate daily target adjustment based on current progress
    adjustment_factor = 1.0
    
    if goal != "Balanced Diet"
      metric = targets[:metric].to_sym
      target_per_day = targets[:target_per_day]
      days_completed = consumed[:days_tracked] || 1
      avg_consumed = consumed[metric].to_f / days_completed
      
      # If we're under/over target, adjust future recommendations
      if avg_consumed > 0
        adjustment_factor = target_per_day / avg_consumed
        adjustment_factor = [0.7, [adjustment_factor, 1.3].min].max  # Clamp between 0.7 and 1.3
      end
    end
    
    # Breakfast
    base_grams = rand(150..250)
    recommended_grams = (base_grams * adjustment_factor).round
    meal_entries.create!(
      food_item: foods.sample,
      day_index: day,
      meal_type: "breakfast",
      grams: [100, [recommended_grams, 400].min].max
    )
    
    # Lunch
    base_grams = rand(200..350)
    recommended_grams = (base_grams * adjustment_factor).round
    meal_entries.create!(
      food_item: foods.sample,
      day_index: day,
      meal_type: "lunch",
      grams: [150, [recommended_grams, 500].min].max
    )
    
    # Dinner
    base_grams = rand(200..300)
    recommended_grams = (base_grams * adjustment_factor).round
    meal_entries.create!(
      food_item: foods.sample,
      day_index: day,
      meal_type: "dinner",
      grams: [150, [recommended_grams, 450].min].max
    )
  end

  def generate_day_recommendations(day, foods)
    # Calculate recommended grams based on goal progress
    targets = goal_targets
    consumed = actual_nutrition_consumed
    days_remaining = duration_days - day
    days_remaining = 1 if days_remaining <= 0
    
    # Calculate daily target adjustment based on current progress
    adjustment_factor = 1.0
    
    if goal != "Balanced Diet"
      metric = targets[:metric].to_sym
      target_per_day = targets[:target_per_day]
      days_completed = consumed[:days_tracked] || 1
      avg_consumed = consumed[metric].to_f / days_completed
      
      # If we're under/over target, adjust future recommendations
      if avg_consumed > 0
        adjustment_factor = target_per_day / avg_consumed
        adjustment_factor = [0.7, [adjustment_factor, 1.3].min].max  # Clamp between 0.7 and 1.3
      end
    end
    
    # Generate multiple recommendations for breakfast
    foods.sample(4).each do |food|
      base_grams = rand(150..250)
      recommended_grams = (base_grams * adjustment_factor).round
      meal_recommendations.create!(
        food_item: food,
        day_index: day,
        meal_type: "breakfast",
        recommended_grams: [100, [recommended_grams, 400].min].max
      )
    end
    
    # Generate multiple recommendations for lunch
    foods.sample(4).each do |food|
      base_grams = rand(200..350)
      recommended_grams = (base_grams * adjustment_factor).round
      meal_recommendations.create!(
        food_item: food,
        day_index: day,
        meal_type: "lunch",
        recommended_grams: [150, [recommended_grams, 500].min].max
      )
    end
    
    # Generate multiple recommendations for dinner
    foods.sample(4).each do |food|
      base_grams = rand(200..300)
      recommended_grams = (base_grams * adjustment_factor).round
      meal_recommendations.create!(
        food_item: food,
        day_index: day,
        meal_type: "dinner",
        recommended_grams: [150, [recommended_grams, 450].min].max
      )
    end
  end
end
