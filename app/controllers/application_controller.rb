class ApplicationController < ActionController::Base
  before_action :require_login

  helper_method :current_account, :logged_in?

  private

  def current_account
    @current_account ||= Account.find_by(id: session[:account_id]) if session[:account_id]
  end

  def logged_in?
    current_account.present?
  end

  def require_login
    return if logged_in?

    redirect_to login_path, alert: "Please sign in first"
  end
end
