class SessionsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:guest]

  def guest
    user = User.find_by(email: 'guest@example.com')

    if user
      sign_in(user)
      redirect_to matches_path, notice: "Logged in as Guest User"
    else
      redirect_to new_user_session_path, alert: "Guest user not found."
    end
  end
end
