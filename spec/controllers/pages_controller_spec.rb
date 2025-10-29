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
  end
end
