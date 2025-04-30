module Api
    module V1
      class BaseController < ApplicationController
        include ActionController::HttpAuthentication::Token::ControllerMethods
        include JsonApiErrors
        
        before_action :authenticate_request
        
        private
        
        def authenticate_request
          @current_user = User.find_by(id: decoded_token[:user_id]) if decoded_token
          render json: { error: 'Unauthorized' }, status: :unauthorized unless @current_user
        end
        
        def decoded_token
          header = request.headers['Authorization']
          header = header.split(' ').last if header
          begin
            JsonWebToken.decode(header)
          rescue JWT::DecodeError
            nil
          end
        end
        
        def current_user
          @current_user
        end
        
        def render_error(message, status = :unprocessable_entity)
          errors = [{
            detail: message,
            status: Rack::Utils.status_code(status).to_s
          }]
          
          render json: { errors: errors }, status: status
        end
      end
    end
  end