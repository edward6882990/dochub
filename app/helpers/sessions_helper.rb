module SessionsHelper
  def sign_in(user, remember_user: false)
    session[:user_id] = user.id
    remember(user) if remember_user
  end

  def sign_out
    session.delete(:user_id)
    forget(@current_user)
    @current_user = nil
  end

  def remember(user)
    user.remember_me!

    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  def forget(user)
    cookies.delete(:remember_token)
    cookies.delete(:user_id)

    user.forget_me!
  end

  def user_signed_in?
    !current_user.nil?
  end

  def current_user
    if @current_user
      @current_user
    elsif user_id = session[:user_id]
      @current_user = User.find_by(id: user_id)
    elsif user_id = cookies.signed[:user_id]
      user = User.find_by(id: user_id)
      if user && user.authenticated?(cookies[:remember_token], user_id)
        @current_user = user
      end
    end
  end
end
