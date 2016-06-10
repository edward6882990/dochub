module RequestsHelper
  def authenticate_user!
    unless user_signed_in?
      unauthorized! "This operation is not allowed!"
    end
  end

  def invalid_request!(error)
    render :json => { error: error }, status: 422
  end

  def unauthorized!(message)
    error = { message: message }
    render :json => { error: error }, status: 401
  end

  def forbidden!(message)
    error = { message: message }
    render :json => { error: error }, status: 403
  end

  def not_found!(model, id)
    error = { message: "#{model.name} #{id} is not found!" }
    render :json => { error: error }, status: 404
  end

  def created!(data)
    render :json => data, status: 201
  end

  def success!(data)
    render :json => data, status: 200
  end
end
