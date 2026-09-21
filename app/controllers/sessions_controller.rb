class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_path, alert: "Try again later." }
  skip_before_action :verify_authenticity_token, only: [:create]

  def new
  end

  def create
    if user = User.authenticate_by(params.permit(:nickname, :password))
      session = user.sessions.create!
      cookies.signed.permanent[:session_id] = session.id

      redirect_to root_path, notice: "Вы успешно вошли в игру!"
    else
      redirect_to new_session_path, alert: "Неверный никнейм или пароль."
    end
  end


  def destroy
    terminate_session
    redirect_to new_session_path, status: :see_other
  end
end
