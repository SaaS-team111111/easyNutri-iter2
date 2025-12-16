class SessionsController < ApplicationController
  skip_before_action :require_login, only: [:new, :create]

  def new
  end

  def create
    account = Account.find_by(username: params[:username])

    if account&.authenticate(params[:password])
      session[:account_id] = account.id
      redirect_to root_path, notice: "Signed in successfully"
    else
      flash.now[:alert] = "Invalid username or password"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    reset_session
    redirect_to login_path, notice: "Signed out"
  end
end

