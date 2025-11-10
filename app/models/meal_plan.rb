class MealPlan < ApplicationRecord
  belongs_to :user
  has_many :meal_entries, dependent: :destroy
  has_many :daily_trackings, dependent: :destroy

  GOALS = ["Weight Loss", "Muscle Gain", "Low Sodium", "Balanced Diet"]

  validates :goal, presence: true, inclusion: { in: GOALS }
  validates :duration_days,
    presence: true,
    numericality: { only_integer: true, greater_than: 0 }
  validates :status, presence: true
  validates :current_day,
    numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :user_can_only_have_one_active_plan, on: :create

  # Get meals for a specific day
  def meals_for_day(day_index)
    meal_entries.where(day_index: day_index).includes(:food_item).order(:meal_type)
  end

  # Get today's meals
  def today_meals
    meals_for_day(current_day)
  end

  # Check if meal plan is completed
  def completed?
    current_day >= duration_days
  end

  # Advance to next day with feedback
  def advance_day!(feedback)
    return false if completed?
    
    transaction do
      daily_trackings.create!(
        day_index: current_day,
        feedback: feedback
      )
      
      increment!(:current_day)
      
      # Regenerate future meals based on feedback
      regenerate_meals_from(current_day) if current_day < duration_days
    end
    
    true
  end

  private
  
  def user_can_only_have_one_active_plan
    if status == "active" && user.meal_plans.where(status: "active").where.not(id: id).exists?
      errors.add(:base, "User already has an active meal plan")
    end
  end

  def regenerate_meals_from(start_day)
    # Delete future meals
    meal_entries.where("day_index >= ?", start_day).delete_all
    
    # Get feedback history
    feedback_counts = daily_trackings.group(:feedback).count
    
    # Adjust food selection based on feedback
    all_foods = FoodItem.all.to_a
    return if all_foods.empty?
    
    # Calculate adjustment factor based on feedback
    more_healthy_count = feedback_counts["more_healthy"] || 0
    less_healthy_count = feedback_counts["less_healthy"] || 0
    
    foods = select_foods_for_goal(all_foods, more_healthy_count, less_healthy_count)
    
    # Generate meals for remaining days
    (start_day...duration_days).each do |day|
      generate_day_meals(day, foods)
    end
  end

  def select_foods_for_goal(all_foods, more_healthy_count, less_healthy_count)
    # Adjust selection strictness based on user feedback
    strictness = 1.0 + (more_healthy_count * 0.1) - (less_healthy_count * 0.1)
    strictness = [0.5, [strictness, 2.0].min].max  # Clamp between 0.5 and 2.0
    
    count = [8, (8 * strictness).to_i].max
    
    case goal
    when "Low Sodium"
      all_foods.sort_by { |f| f.sodium_mg_per_100g }.take(count)
    when "Weight Loss"
      all_foods.sort_by { |f| f.calories_per_100g.to_f / (f.protein_per_100g + 1) }.take(count)
    when "Muscle Gain"
      all_foods.sort_by { |f| -f.protein_per_100g }.take(count)
    when "Balanced Diet"
      all_foods.sample(count)
    else
      all_foods.sample(count)
    end
  end

  def generate_day_meals(day, foods)
    MealEntry.create!(
      meal_plan: self,
      food_item: foods.sample,
      day_index: day,
      meal_type: "breakfast",
      grams: rand(150..250)
    )
    
    MealEntry.create!(
      meal_plan: self,
      food_item: foods.sample,
      day_index: day,
      meal_type: "lunch",
      grams: rand(200..350)
    )
    
    MealEntry.create!(
      meal_plan: self,
      food_item: foods.sample,
      day_index: day,
      meal_type: "dinner",
      grams: rand(200..300)
    )
  end
end
