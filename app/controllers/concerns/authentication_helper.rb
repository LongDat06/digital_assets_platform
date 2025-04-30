module AuthenticationHelper
  extend ActiveSupport::Concern

  included do
    attr_reader :current_user
  end

  def authenticate_request
    return if request.headers['Authorization'].blank?
    
    @current_user = AuthenticationService.authenticate_request(request.headers)
  rescue ExceptionHandler::InvalidToken, ExceptionHandler::ExpiredSignature => e
    render json: { error: e.message }, status: :unauthorized
  end

  def logged_in?
    current_user.present?
  end

  def require_login
    unless logged_in?
      render json: { error: 'Please log in' }, status: :unauthorized
    end
  end

  def require_admin
    unless current_user&.admin?
      render json: { error: 'Admin access required' }, status: :forbidden
    end
  end

  def require_creator
    unless current_user&.creator?
      render json: { error: 'Creator access required' }, status: :forbidden
    end
  end

  def require_customer
    unless current_user&.customer?
      render json: { error: 'Customer access required' }, status: :forbidden
    end
  end

  def authorize_user(user)
    unless current_user == user
      render json: { error: 'Unauthorized access' }, status: :forbidden
    end
  end
end
