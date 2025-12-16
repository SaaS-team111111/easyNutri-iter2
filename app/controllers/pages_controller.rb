class PagesController < ApplicationController
  def dashboard
    @users = current_account.users

    return unless params[:user_id].present?

    @selected_user = @users.find_by(id: params[:user_id])
    return unless @selected_user

      @just_completed = params[:just_completed] == 'true'
      
    @current_meal_plan =
      if @just_completed && params[:meal_plan_id].present?
        @selected_user.meal_plans.find_by(id: params[:meal_plan_id])
      else
        @selected_user.current_meal_plan
      end
      
      if @current_meal_plan
        @today_meals = @current_meal_plan.today_meals.group_by(&:meal_type)
        @today_recommendations = @current_meal_plan.today_recommendations || {}
        @today_actual_meals = @current_meal_plan.today_actual_meals || {}
        @current_day_number = @current_meal_plan.current_day + 1
        @total_days = @current_meal_plan.duration_days
      else
        @today_meals = {}
        @today_recommendations = {}
        @today_actual_meals = {}
    end
  end
end
