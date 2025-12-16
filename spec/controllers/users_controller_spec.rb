require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let(:account) { create(:account) }
  
  before do
    routes.draw do
      root 'pages#dashboard'
      get '/login', to: 'sessions#new', as: :login
      resources :users, only: [:new, :create, :edit, :update, :destroy]
    end
    login_account(account)
  end

  describe 'GET #new' do
    it 'assigns a new user and renders new template' do
      get :new
      expect(assigns(:user)).to be_a_new(User)
      expect(response).to be_successful
      expect(response).to render_template(:new)
    end
  end

  describe 'POST #create' do
    it 'creates user and redirects on success' do
      expect {
        post :create, params: { user: { name: 'a', height_cm: 165, weight_kg: 55, age: 21, sex: 'F' } }
      }.to change(User, :count).by(1)
      expect(response).to redirect_to(root_path)
      expect(flash[:notice]).to eq("User created successfully!")
    end

    it 'renders :new on failure' do
      expect {
        post :create, params: { user: { name: '' } }
      }.not_to change(User, :count)
      expect(response).to render_template(:new)
      expect(assigns(:user).errors[:name]).to be_present
    end
  end

  describe 'GET #edit' do
    let(:user) { create(:user, account: account) }

    it 'assigns the requested user and renders edit template' do
      get :edit, params: { id: user.id }
      expect(assigns(:user)).to eq(user)
      expect(response).to be_successful
      expect(response).to render_template(:edit)
    end
  end

  describe 'PATCH #update' do
    let(:user) { create(:user, account: account, name: 'Old Name') }

    context 'with valid parameters' do
      it 'updates the user and redirects' do
        patch :update, params: { 
          id: user.id, 
          user: { name: 'New Name', height_cm: 170, weight_kg: 65, age: 25, sex: 'M' } 
        }
        
        user.reload
        expect(user.name).to eq('New Name')
        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to eq("User updated successfully!")
      end
    end

    context 'with invalid parameters' do
      it 'renders :edit on failure' do
        patch :update, params: { id: user.id, user: { name: '' } }
        
        expect(response).to render_template(:edit)
        expect(assigns(:user).errors[:name]).to be_present
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:user) { create(:user, account: account) }

    it 'destroys the user and redirects' do
      expect {
        delete :destroy, params: { id: user.id }
      }.to change(User, :count).by(-1)
      
      expect(response).to redirect_to(root_path)
      expect(flash[:notice]).to eq("User deleted successfully!")
    end
  end
end
