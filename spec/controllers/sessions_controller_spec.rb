require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  let(:account) { create(:account, username: 'testuser', password: 'password123') }

  before do
    routes.draw do
      root 'pages#dashboard'
      get '/login', to: 'sessions#new', as: :login
      post '/login', to: 'sessions#create'
      delete '/logout', to: 'sessions#destroy'
    end
  end

  describe 'GET #new' do
    it 'renders the new template' do
      get :new
      expect(response).to be_successful
      expect(response).to render_template(:new)
    end
  end

  describe 'POST #create' do
    context 'with valid credentials' do
      it 'sets session and redirects to root' do
        # Ensure account is created before the request
        account # Force evaluation of let
        
        post :create, params: { username: 'testuser', password: 'password123' }
        
        # In controller specs, session is available directly via session helper
        expect(session[:account_id]).to eq(account.id)
        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to eq("Signed in successfully")
      end
    end

    context 'with invalid credentials' do
      it 'does not set session with wrong password' do
        post :create, params: { username: 'testuser', password: 'wrongpassword' }
        
        expect(session[:account_id]).to be_nil
        expect(response).to render_template(:new)
        expect(response).to have_http_status(:unprocessable_content)
        expect(flash[:alert]).to eq("Invalid username or password")
      end

      it 'does not set session with non-existent username' do
        post :create, params: { username: 'nonexistent', password: 'password123' }
        
        expect(session[:account_id]).to be_nil
        expect(response).to render_template(:new)
        expect(flash[:alert]).to eq("Invalid username or password")
      end
    end
  end

  describe 'DELETE #destroy' do
    before do
      session[:account_id] = account.id
    end

    it 'clears session and redirects to login' do
      delete :destroy
      
      expect(session[:account_id]).to be_nil
      expect(response).to redirect_to(login_path)
      expect(flash[:notice]).to eq("Signed out")
    end
  end
end

