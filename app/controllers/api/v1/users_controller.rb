module Api
  module V1
    class UsersController < BaseController
      before_action :set_user, only: [:show, :update]
      skip_before_action :authenticate_request, only: [:index]

      def index
        @users = User.all
        render json: @users, each_serializer: UserSerializer
      end

      def show
        render json: @user, serializer: UserSerializer
      end

      def update
        if @user == current_user && @user.update(user_params)
          render json: @user, serializer: UserSerializer
        else
          render json: { errors: @user.errors }, status: :unprocessable_entity
        end
      end

      def profile
        render json: current_user, serializer: UserSerializer
      end

      private

      def set_user
        @user = User.find(params[:id])
      end

      def user_params
        params.permit(:email, :username, :password, :password_confirmation)
      end
    end
  end
end
