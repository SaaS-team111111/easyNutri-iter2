require 'rails_helper'

RSpec.describe AccountsController, type: :controller do
  before do
    routes.draw do
      root 'pages#dashboard'
      get '/login', to: 'sessions#new', as: :login
      resources :accounts, only: [:new, :create]
    end
  end

  describe 'GET #new' do
    it 'assigns a new account and renders new template' do
      get :new
      expect(assigns(:account)).to be_a_new(Account)
      expect(response).to be_successful
      expect(response).to render_template(:new)
    end
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      it 'creates a new account and sets session' do
        expect {
          post :create, params: { 
            account: { 
              username: 'testuser', 
              password: 'password123', 
              password_confirmation: 'password123' 
            } 
          }
        }.to change(Account, :count).by(1)
        
        expect(session[:account_id]).to eq(Account.last.id)
        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to eq("Account created successfully")
      end
    end

    context 'with invalid parameters' do
      it 'does not create account when password confirmation does not match' do
        expect {
          post :create, params: { 
            account: { 
              username: 'testuser', 
              password: 'password123', 
              password_confirmation: 'wrongpassword' 
            } 
          }
        }.not_to change(Account, :count)
        
        expect(response).to render_template(:new)
        expect(response).to have_http_status(:unprocessable_content)
        expect(assigns(:account).errors[:password_confirmation]).to be_present
      end

      it 'does not create account when username is duplicate' do
        create(:account, username: 'existinguser')
        
        expect {
          post :create, params: { 
            account: { 
              username: 'existinguser', 
              password: 'password123', 
              password_confirmation: 'password123' 
            } 
          }
        }.not_to change(Account, :count)
        
        expect(response).to render_template(:new)
        expect(assigns(:account).errors[:username]).to be_present
      end

      it 'does not create account when username is blank' do
        expect {
          post :create, params: { 
            account: { 
              username: '', 
              password: 'password123', 
              password_confirmation: 'password123' 
            } 
          }
        }.not_to change(Account, :count)
        
        expect(response).to render_template(:new)
        expect(assigns(:account).errors[:username]).to be_present
      end
    end
  end
end

