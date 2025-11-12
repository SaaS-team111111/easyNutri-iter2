require 'rails_helper'

RSpec.describe MealPlansController, type: :controller do
  before do
    routes.draw do
      root 'pages#dashboard'
      resources :meal_plans, only: [:new, :create, :show] do
        member do
          post :advance_day
        end
      end
    end
    create(:food_item, name: 'Chicken')
    create(:food_item, name: 'Rice')
    create(:food_item, name: 'Broccoli')
  end

  describe 'GET #new' do
    it 'assigns a new meal plan and all users' do
      user1 = create(:user, name: 'a')
      user2 = create(:user, name: 'b')
      
      get :new
      
      expect(assigns(:meal_plan)).to be_a_new(MealPlan)
      expect(assigns(:users)).to match_array([user1, user2])
      expect(response).to be_successful
      expect(response).to render_template(:new)
    end
  end

  describe 'POST #create' do
    let(:user) { create(:user) }

    it 'creates a plan with meal entries and redirects to dashboard' do
      expect {
        post :create, params: { meal_plan: { user_id: user.id, goal: 'Weight Loss', duration_days: 7 } }
      }.to change(MealPlan, :count).by(1).and change(MealEntry, :count).by(21)
      
      expect(response).to have_http_status(:found)
      expect(response.location).to match(%r{\?user_id=\d+})
    end

    it 'creates Low Sodium plan with appropriate food selection' do
      post :create, params: { meal_plan: { user_id: user.id, goal: 'Low Sodium', duration_days: 3 } }
      expect(response).to have_http_status(:found)
      expect(MealPlan.last.goal).to eq('Low Sodium')
      expect(MealEntry.count).to eq(9)
    end

    it 'creates Muscle Gain plan with appropriate food selection' do
      post :create, params: { meal_plan: { user_id: user.id, goal: 'Muscle Gain', duration_days: 5 } }
      expect(response).to have_http_status(:found)
      expect(MealPlan.last.goal).to eq('Muscle Gain')
      expect(MealEntry.count).to eq(15)
    end

    it 'creates Balanced Diet plan with appropriate food selection' do
      post :create, params: { meal_plan: { user_id: user.id, goal: 'Balanced Diet', duration_days: 1 } }
      expect(response).to have_http_status(:found)
      expect(MealPlan.last.goal).to eq('Balanced Diet')
      expect(MealEntry.count).to eq(3)
    end

    it 'renders :new on validation error' do
      create(:user)
      post :create, params: { meal_plan: { user_id: nil, goal: nil, duration_days: nil } }
      expect(response).to render_template(:new)
      expect(assigns(:users)).to be_present
      expect(assigns(:meal_plan).errors).to be_present
    end

    it 'executes replace_existing logic (destroys active plans when present)' do
      user = create(:user)
      
      # Test that the destroy_all is called when replace_existing is true
      expect_any_instance_of(ActiveRecord::Relation).to receive(:destroy_all).and_call_original
      
      post :create, params: { 
        meal_plan: { user_id: user.id, goal: 'Weight Loss', duration_days: 5 },
        replace_existing: 'true'
      }
      
      expect(response).to have_http_status(:found)
      expect(user.meal_plans.where(status: 'active').count).to eq(1)
    end

    it 'prevents creating new plan when user has active plan (validation error)' do
      user = create(:user)
      existing_plan = create(:meal_plan, user: user, status: 'active')
      
      post :create, params: { meal_plan: { user_id: user.id, goal: 'Muscle Gain', duration_days: 7 } }
      
      expect(response).to render_template(:new)
      expect(assigns(:meal_plan).errors[:base]).to include('User already has an active meal plan')
      expect(user.meal_plans.where(status: 'active').count).to eq(1) # No new plan created
      expect(MealPlan.exists?(existing_plan.id)).to be true # Old plan still exists
    end
  end

  describe 'GET #show' do
    it 'renders show with entries grouped by day' do
      plan = create(:meal_plan, status: 'generated')
      create(:meal_entry, meal_plan: plan, day_index: 0, meal_type: 'breakfast')
      create(:meal_entry, meal_plan: plan, day_index: 0, meal_type: 'lunch')
      
      get :show, params: { id: plan.id }
      expect(response).to be_successful
      expect(assigns(:meal_plan)).to eq(plan)
      expect(assigns(:entries_by_day)).to be_a(Hash)
    end

    it 'assigns goal progress and nutrition data' do
      plan = create(:meal_plan, status: 'active', current_day: 2)
      food = create(:food_item)
      create(:meal_entry, meal_plan: plan, food_item: food, day_index: 0)
      create(:actual_meal_entry, meal_plan: plan, food_item: food, day_index: 0)
      
      get :show, params: { id: plan.id }
      
      expect(assigns(:goal_progress)).to be_present
      expect(assigns(:goal_targets)).to be_present
      expect(assigns(:nutrition_consumed)).to be_present
    end
  end

  describe 'POST #advance_day' do
    let(:user) { create(:user) }
    let(:plan) { create(:meal_plan, user: user, duration_days: 3, current_day: 0, status: 'active') }

    it 'advances the day with feedback' do
      expect {
        post :advance_day, params: { id: plan.id, feedback: 'strictly_followed' }
      }.to change { plan.reload.current_day }.from(0).to(1)
      
      expect(response).to have_http_status(:found)
    end

    it 'creates daily tracking entry' do
      expect {
        post :advance_day, params: { id: plan.id, feedback: 'less_healthy' }
      }.to change { plan.daily_trackings.count }.by(1)
    end

    it 'saves actual meals when provided' do
      food = create(:food_item)
      actual_meals = {
        breakfast: { food_item_id: food.id, grams: 100 },
        lunch: { food_item_id: food.id, grams: 150 }
      }
      
      expect {
        post :advance_day, params: { id: plan.id, feedback: 'strictly_followed', actual_meals: actual_meals }
      }.to change { plan.actual_meal_entries.count }.by(2)
    end

    it 'marks plan as completed and redirects when advancing on last day' do
      plan.update(current_day: 2)  # Last day (duration_days = 3)
      
      post :advance_day, params: { id: plan.id, feedback: 'strictly_followed' }
      
      expect(plan.reload.status).to eq('completed')
      expect(plan.completed?).to be true
      expect(response).to have_http_status(:found)
      expect(response.location).to include('just_completed=true')
    end

    it 'returns alert when trying to advance already completed plan' do
      completed_plan = create(:meal_plan, user: user, duration_days: 3, current_day: 3, status: 'completed')
      
      post :advance_day, params: { id: completed_plan.id, feedback: 'strictly_followed' }
      
      expect(response).to have_http_status(:found)
      expect(flash[:alert]).to be_present
    end
  end
end
