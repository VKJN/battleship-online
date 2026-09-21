class UsersController < ApplicationController
  allow_unauthenticated_access only: [ :new, :create ]
  skip_before_action :verify_authenticity_token, only: [:create]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      session = @user.sessions.create!
      cookies.signed.permanent[:session_id] = session.id
      
      redirect_to root_path, notice: "Вы успешно зарегистрировались!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
  def user_params
    params.require(:user).permit(:nickname, :password, :password_confirmation)
  end
end
