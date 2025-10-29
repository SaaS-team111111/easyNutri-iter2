require 'rails_helper'

RSpec.describe MealPlansController, type: :controller do
  before do
    routes.draw do
      resources :meal_plans, only: [:new, :create, :show]
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

    it 'creates a plan with meal entries and redirects to show' do
      expect {
        post :create, params: { meal_plan: { user_id: user.id, goal: 'Weight Loss', duration_days: 7 } }
      }.to change(MealPlan, :count).by(1).and change(MealEntry, :count).by(21)
      
      expect(response).to have_http_status(:found)
      expect(response.location).to match(%r{/meal_plans/\d+})
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
  end
end
