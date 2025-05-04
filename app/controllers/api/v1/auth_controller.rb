module Api
  module V1
    class AuthController < ApplicationController
      skip_before_action :authenticate_request, only: [:register, :login]

      def register
        user = User.new(user_params)
        if user.save
          auth_token = JsonWebToken.encode(user_id: user.id)
          response = {
            message: 'User created successfully',
            auth_token: auth_token,
            user: UserSerializer.new(user)
          }
          render json: response, status: :created
        else
          render json: { errors: user.errors }, status: :unprocessable_entity
        end
      end

      def login
        begin
          auth_info = AuthenticationService.authenticate(params[:email], params[:password])
          response = {
            message: 'Login successful',
            auth_token: auth_info[:token],
            user: UserSerializer.new(auth_info[:user])
          }
          render json: response
        rescue ExceptionHandler::AuthenticationError => e
          render json: { error: e.message }, status: :unauthorized
        end
      end

      private

      def user_params
        params.permit(
          :email,
          :username,
          :password,
          :password_confirmation,
          :role
        )
      end
    end
  end
end
