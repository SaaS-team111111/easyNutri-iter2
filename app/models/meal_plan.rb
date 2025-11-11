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
    if status == "active" && user.meal_plans.where(status: "active").where.not(id: id).exists?
      errors.add(:base, "User already has an active meal plan")
    end
  end

  def regenerate_recommendations_from(start_day)
    # Delete future recommendations
    meal_recommendations.where("day_index >= ?", start_day).delete_all
    
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
    
    # Generate recommendations for remaining days
    (start_day...duration_days).each do |day|
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

  def generate_day_recommendations(day, foods)
    # Generate multiple recommendations for breakfast
    foods.sample(4).each do |food|
      meal_recommendations.create!(
        food_item: food,
        day_index: day,
        meal_type: "breakfast",
        recommended_grams: rand(150..250)
      )
    end
    
    # Generate multiple recommendations for lunch
    foods.sample(4).each do |food|
      meal_recommendations.create!(
        food_item: food,
        day_index: day,
        meal_type: "lunch",
        recommended_grams: rand(200..350)
      )
    end
    
    # Generate multiple recommendations for dinner
    foods.sample(4).each do |food|
      meal_recommendations.create!(
        food_item: food,
        day_index: day,
        meal_type: "dinner",
        recommended_grams: rand(200..300)
      )
    end
  end
end
