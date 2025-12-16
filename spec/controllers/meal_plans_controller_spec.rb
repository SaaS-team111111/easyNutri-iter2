require 'rails_helper'

RSpec.describe MealPlansController, type: :controller do
  let(:account) { create(:account) }
  
  before do
    routes.draw do
      root 'pages#dashboard'
      get '/login', to: 'sessions#new', as: :login
      resources :meal_plans, only: [:new, :create, :show] do
        member do
          post :advance_day
        end
      end
    end
    login_account(account)
    create(:food_item, name: 'Chicken')
    create(:food_item, name: 'Rice')
    create(:food_item, name: 'Broccoli')
  end

  describe 'GET #new' do
    it 'assigns a new meal plan and users' do
      create(:user, account: account)
      get :new
      expect(assigns(:meal_plan)).to be_a_new(MealPlan)
      expect(response).to render_template(:new)
    end
  end

  describe 'POST #create' do
    let(:user) { create(:user, account: account) }

    it 'creates meal plan and generates entries' do
      expect {
        post :create, params: { meal_plan: { user_id: user.id, goal: 'Weight Loss', duration_days: 3 } }
      }.to change(MealPlan, :count).by(1)
      expect(MealEntry.count).to be > 0
      expect(response).to have_http_status(:found)
    end

    it 'shows replace modal for active plan and handles replace_existing' do
      create(:meal_plan, user: user, status: 'active')
      post :create, params: { meal_plan: { user_id: user.id, goal: 'Muscle Gain', duration_days: 7 } }
      expect(assigns(:show_replace_modal)).to be true
      
      post :create, params: { meal_plan: { user_id: user.id, goal: 'Low Sodium', duration_days: 5 }, replace_existing: 'true' }
      expect(response).to have_http_status(:found)
    end

    it 'redirects with alert when user is not authorized (user from different account)' do
      other_account = create(:account)
      other_user = create(:user, account: other_account)
      
      post :create, params: { meal_plan: { user_id: other_user.id, goal: 'Weight Loss', duration_days: 7 } }
      
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("Unauthorized user")
    end

    it 'renders :new when meal plan save fails' do
      allow_any_instance_of(MealPlan).to receive(:save).and_return(false)
      allow_any_instance_of(MealPlan).to receive(:errors).and_return(double(full_messages: ['Error message']))
      
      post :create, params: { meal_plan: { user_id: user.id, goal: 'Weight Loss', duration_days: 7 } }
      
      expect(response).to render_template(:new)
      expect(assigns(:users)).to be_present
    end
  end

  describe 'GET #show' do
    it 'renders show with entries and progress' do
      user = create(:user, account: account)
      plan = create(:meal_plan, user: user, status: 'active', current_day: 1)
      create(:meal_entry, meal_plan: plan, day_index: 0)
      
      get :show, params: { id: plan.id }
      expect(response).to be_successful
      expect(assigns(:entries_by_day)).to be_a(Hash)
    end
  end

  describe 'POST #advance_day' do
    let(:user) { create(:user, account: account) }
    let(:plan) { create(:meal_plan, user: user, duration_days: 3, current_day: 0, status: 'active') }

    it 'advances day, creates tracking, and saves actual meals' do
      food = create(:food_item)
      expect {
        post :advance_day, params: { 
          id: plan.id, feedback: 'strictly_followed',
          actual_meals: { breakfast: [{ food_item_id: food.id, grams: 100 }] }
        }
      }.to change { plan.reload.current_day }.by(1)
        .and change { plan.daily_trackings.count }.by(1)
        .and change { plan.actual_meal_entries.count }.by(1)
    end

    it 'completes plan on last day' do
      plan.update(current_day: 2)
      post :advance_day, params: { id: plan.id, feedback: 'strictly_followed' }
      expect(plan.reload.status).to eq('completed')
      expect(response.location).to include('just_completed=true')
    end

    it 'redirects with alert when meal plan is already completed' do
      plan.update(status: 'completed', current_day: 3)
      allow_any_instance_of(MealPlan).to receive(:advance_day!).and_return(false)
      
      post :advance_day, params: { id: plan.id, feedback: 'strictly_followed' }
      
      expect(response).to redirect_to(root_path(user_id: plan.user_id))
      expect(flash[:alert]).to eq("Meal plan is already completed!")
    end

    it 'handles advance_day with array of actual meals for different meal types' do
      food1 = create(:food_item)
      food2 = create(:food_item)
      post :advance_day, params: { 
        id: plan.id, 
        feedback: 'strictly_followed',
        actual_meals: { 
          breakfast: [{ food_item_id: food1.id, grams: 200 }],
          lunch: [{ food_item_id: food2.id, grams: 300 }]
        }
      }
      
      expect(plan.reload.current_day).to eq(1)
      expect(plan.actual_meal_entries.where(meal_type: 'breakfast').count).to eq(1)
      expect(plan.actual_meal_entries.where(meal_type: 'lunch').count).to eq(1)
    end
  end
end
