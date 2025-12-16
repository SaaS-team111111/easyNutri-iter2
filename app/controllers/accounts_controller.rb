class AccountsController < ApplicationController
  skip_before_action :require_login, only: [:new, :create]

  def new
    @account = Account.new
  end

  def create
    @account = Account.new(account_params)
    if @account.save
      session[:account_id] = @account.id
      redirect_to root_path, notice: "Account created successfully"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def account_params
    params.require(:account).permit(:username, :password, :password_confirmation)
  end
end

