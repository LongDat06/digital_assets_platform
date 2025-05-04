module ExceptionHandler
  extend ActiveSupport::Concern

  class AuthenticationError < StandardError; end
  class InvalidToken < StandardError; end
  class ExpiredSignature < StandardError; end
  class MissingToken < StandardError; end
  class UnauthorizedRequest < StandardError; end

  included do
    rescue_from ActiveRecord::RecordInvalid, with: :four_twenty_two
    rescue_from ExceptionHandler::AuthenticationError, with: :unauthorized_request
    rescue_from ExceptionHandler::InvalidToken, with: :four_twenty_two
    rescue_from ExceptionHandler::ExpiredSignature, with: :unauthorized_request
    rescue_from ExceptionHandler::MissingToken, with: :four_twenty_two
    rescue_from ExceptionHandler::UnauthorizedRequest, with: :unauthorized_request

    rescue_from ActiveRecord::RecordNotFound do |e|
      render json: {
        error: {
          message: e.message,
          status: 404
        }
      }, status: :not_found
    end
  end

  private

  def four_twenty_two(e)
    render json: {
      error: {
        message: e.message,
        status: 422
      }
    }, status: :unprocessable_entity
  end

  def unauthorized_request(e)
    render json: {
      error: {
        message: e.message,
        status: 401
      }
    }, status: :unauthorized
  end
end
