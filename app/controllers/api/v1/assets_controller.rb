module Api
  module V1
    class AssetsController < BaseController
      before_action :set_asset, only: [:show, :update, :destroy]
      before_action :ensure_creator, only: [:create, :bulk_import]
      skip_before_action :authenticate_request, only: [:index, :show]

      def index
        @assets = Asset.includes(:creator)
        @assets = @assets.by_creator(params[:creator_id]) if params[:creator_id]
        @assets = @assets.price_range(params[:min_price], params[:max_price]) if params[:min_price] || params[:max_price]
        
        render json: @assets, each_serializer: AssetSerializer
      end

      def show
        render json: @asset, serializer: AssetSerializer
      end

      def create
        @asset = current_user.created_assets.build(asset_params)
        
        if @asset.save
          render json: @asset, serializer: AssetSerializer, status: :created
        else
          render json: { errors: @asset.errors }, status: :unprocessable_entity
        end
      end

      def bulk_import
        result = Asset.bulk_import(current_user, assets_params)
        
        if result
          render json: { message: 'Assets imported successfully' }, status: :created
        else
          render json: { error: 'Failed to import assets' }, status: :unprocessable_entity
        end
      end

      def update
        if @asset.creator == current_user && @asset.update(asset_params)
          render json: @asset, serializer: AssetSerializer
        else
          render json: { errors: @asset.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        if @asset.creator == current_user
          @asset.destroy
          head :no_content
        else
          render json: { error: 'Unauthorized' }, status: :unauthorized
        end
      end

      private

      def set_asset
        @asset = Asset.find(params[:id])
      end

      def asset_params
        params.permit(:title, :description, :file_url, :price)
      end

      def assets_params
        params.require(:assets)
      end

      def ensure_creator
        unless current_user.creator?
          render json: { error: 'Only creators can perform this action' }, 
                 status: :forbidden
        end
      end
    end
  end
end
