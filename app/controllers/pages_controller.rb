class PagesController < ApplicationController
  def dashboard
    @users = User.all
    
    if params[:user_id].present?
      @selected_user = User.find_by(id: params[:user_id])
    end
  end
end
