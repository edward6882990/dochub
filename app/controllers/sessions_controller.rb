require_relative '../serializers/user'

class SessionsController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: [:authenticity_token]

  def authenticity_token
    success! authenticity_token: form_authenticity_token
  end

  def user_sign_in
    user = User.find_by(email: sign_in_params[:email].downcase)

    if user && user.authenticate_with_password(sign_in_params[:password])
      sign_in(user, remember_user: true)

      created!(
        user: Serializers::User.represent(user),
        remember_token: cookies[:remember_token],
        user_id: cookies[:user_id]
      )
    else
      unauthorized!("Invalid email/password combination!")
    end
  end

  def user_sign_out
    sign_out

    success!("User signed out")
  end

protected

  def sign_in_params
    params.require(:session).permit(:email, :password, :remember_me)
  end

end
