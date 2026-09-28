class HomeController < ApplicationController
  def index
    if cookies[:user_id]
      @current_user = User.find_by(id: cookies[:user_id])
    end
  end
end
