class PagesController < ApplicationController
  def dashboard
    @users = User.all
    
    if params[:user_id].present?
      @selected_user = User.find_by(id: params[:user_id])
      @just_completed = params[:just_completed] == 'true'
      
      if @just_completed && params[:meal_plan_id].present?
        @current_meal_plan = MealPlan.find_by(id: params[:meal_plan_id])
      else
        @current_meal_plan = @selected_user&.current_meal_plan
      end
      
      if @current_meal_plan
        @today_meals = @current_meal_plan.today_meals.group_by(&:meal_type)
        @current_day_number = @current_meal_plan.current_day + 1
        @total_days = @current_meal_plan.duration_days
      end
    end
  end
end
