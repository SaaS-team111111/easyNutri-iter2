require 'rails_helper'

RSpec.describe PagesController, type: :controller do
  describe 'GET #dashboard' do
    before do
      routes.draw do
        root 'pages#dashboard'
      end
    end

    it 'assigns users and renders dashboard' do
      users = create_list(:user, 3)
      get :dashboard
      expect(response).to be_successful
      expect(assigns(:users)).to match_array(users)
      expect(response).to render_template(:dashboard)
    end

    it 'assigns selected_user when user_id is provided' do
      user1 = create(:user, name: 'a')
      user2 = create(:user, name: 'b')
      
      get :dashboard, params: { user_id: user1.id }
      
      expect(response).to be_successful
      expect(assigns(:selected_user)).to eq(user1)
      expect(assigns(:selected_user)).not_to eq(user2)
    end

    it 'assigns current_meal_plan and related data when user has active plan' do
      user = create(:user)
      plan = create(:meal_plan, user: user, status: 'active', current_day: 1, duration_days: 7)
      create(:meal_entry, meal_plan: plan, day_index: 1, meal_type: 'breakfast')
      create(:meal_recommendation, meal_plan: plan, day_index: 1, meal_type: 'lunch')
      
      get :dashboard, params: { user_id: user.id }
      
      expect(assigns(:current_meal_plan)).to eq(plan)
      expect(assigns(:today_meals)).to be_a(Hash)
      expect(assigns(:today_recommendations)).to be_a(Hash)
      expect(assigns(:today_actual_meals)).to be_a(Hash)
      expect(assigns(:current_day_number)).to eq(2)
      expect(assigns(:total_days)).to eq(7)
    end

    it 'assigns empty hashes when user has no meal plan' do
      user = create(:user)
      
      get :dashboard, params: { user_id: user.id }
      
      expect(assigns(:current_meal_plan)).to be_nil
      expect(assigns(:today_meals)).to eq({})
      expect(assigns(:today_recommendations)).to eq({})
      expect(assigns(:today_actual_meals)).to eq({})
    end

    it 'shows just completed meal plan when just_completed is true' do
      user = create(:user)
      plan = create(:meal_plan, user: user, status: 'completed', current_day: 7, duration_days: 7)
      
      get :dashboard, params: { user_id: user.id, meal_plan_id: plan.id, just_completed: 'true' }
      
      expect(assigns(:just_completed)).to be true
      expect(assigns(:current_meal_plan)).to eq(plan)
    end
  end
end
