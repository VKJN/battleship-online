class SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create, :destroy]

  def new
  end

  def create
    if user = User.authenticate_by(params.permit(:nickname, :password))
      cookies[:user_id] = user.id.to_s
      redirect_to root_path
    else
      redirect_to new_session_path
    end
  end

  def destroy
    cookies.delete(:user_id)
    redirect_to root_path
  end
end
