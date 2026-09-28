class UsersController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      cookies[:user_id] = @user.id.to_s
      redirect_to root_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:nickname, :password, :password_confirmation)
  end
end
