require 'rails_helper'

RSpec.describe PagesController, type: :controller do
  let(:account) { create(:account) }
  
  describe 'GET #dashboard' do
    before do
      routes.draw do
        root 'pages#dashboard'
        get '/login', to: 'sessions#new', as: :login
      end
      login_account(account)
    end

    it 'assigns users and selected user with meal plan data' do
      user = create(:user, account: account)
      plan = create(:meal_plan, user: user, status: 'active', current_day: 1, duration_days: 7)
      create(:meal_entry, meal_plan: plan, day_index: 1)
      
      get :dashboard, params: { user_id: user.id }
      
      expect(response).to be_successful
      expect(assigns(:selected_user)).to eq(user)
      expect(assigns(:current_meal_plan)).to eq(plan)
      expect(assigns(:today_meals)).to be_a(Hash)
    end

    it 'handles user without meal plan and just_completed flag' do
      user = create(:user, account: account)
      get :dashboard, params: { user_id: user.id }
      expect(assigns(:current_meal_plan)).to be_nil
      
      plan = create(:meal_plan, user: user, status: 'completed')
      get :dashboard, params: { user_id: user.id, meal_plan_id: plan.id, just_completed: 'true' }
      expect(assigns(:just_completed)).to be true
    end
  end
end
