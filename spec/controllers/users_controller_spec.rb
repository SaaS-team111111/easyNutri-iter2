require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  before do
    routes.draw do
      root 'pages#dashboard'
      resources :users, only: [:new, :create]
    end
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
end
