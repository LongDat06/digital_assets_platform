class ApplicationController < ActionController::API
  include ExceptionHandler
  include AuthenticationHelper

  before_action :authenticate_request
  attr_reader :current_user

  private

  def authenticate_request
    return if request.headers['Authorization'].blank?
    
    @current_user = AuthenticationService.authenticate_request(request.headers)
  rescue ExceptionHandler::InvalidToken, ExceptionHandler::ExpiredSignature => e
    render json: { error: e.message }, status: :unauthorized
  end
end
