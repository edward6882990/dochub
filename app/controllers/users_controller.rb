require_relative '../serializers/user'

class UsersController < ApplicationController
  before_filter :authenticate_user!, except: [:create]

  def index
    users = User.all
    users &= User.where(name: index_params[:name]) if index_params[:name]
    users &= User.where(vendor: !!index_params[:vendor]) if index_params[:vendor]

    success! ::Serializers::User.to_hash users, include_items: index_params[:include_items]
  end

  def get_by_token
    if user_signed_in?
      success! ::Serializers::User.represent(current_user)
    else
      unauthorized!(message: "You must sign in to procceed!")
    end
  end

  def create
    new_user = User.new(sign_up_params)

    if new_user.valid?
      new_user.save

      created! Serializers::User.represent(new_user)
    else
      invalid_request! message: new_user.errors.full_messages.first
    end
  end

  def udpate
    user_id = update_params.fetch(:id)
    check_authorization_for_update(user_id)

    user = User.find(user_id) || not_fount!(User, user_id)
    user.udpate(update_params)

    success! Serializers::User.represent(user)
  end


protected

  def index_params
    params.permit(:name, :vendor, :include_items)
  end

  def sign_up_params
    params.permit(:name, :email, :password, :password_confirmation)
  end

  def items_params
    params.permit(:user_id)
  end

  def check_authorization_for_update(user_id)
    if current_user.id != user_id
      unauthorized!(error: { message: "This operation is not authorized!"})
    end
  end

end
