module Api
  module V1
    class PurchasesController < BaseController
      before_action :set_purchase, only: [:show, :download]
      before_action :ensure_customer, only: [:create]

      def index
        @purchases = current_user.purchases.includes(:asset)
        render json: @purchases, each_serializer: PurchaseSerializer
      end

      def show
        if @purchase.customer == current_user
          render json: @purchase, serializer: PurchaseSerializer
        else
          render json: { error: 'Unauthorized' }, status: :unauthorized
        end
      end

      def create
        if purchase_params[:asset_ids].present?
          # Xử lý bulk purchase
          result = BulkPurchaseService.create(current_user, purchase_params[:asset_ids])
          
          if result[:success]
            render json: {
              message: 'Purchases created successfully',
              purchases: ActiveModelSerializers::SerializableResource.new(result[:purchases], each_serializer: PurchaseSerializer),
              total_amount: result[:total_amount]
            }, status: :created
          else
            render json: { 
              error: 'Failed to create purchases',
              details: result[:errors]
            }, status: :unprocessable_entity
          end
        else
          # Xử lý single purchase
          @purchase = current_user.purchases.build(
            asset_id: purchase_params[:asset_id],
            amount: Asset.find(purchase_params[:asset_id]).price,
            status: 'pending'
          )

          if @purchase.save
            render json: {
              message: 'Purchase created successfully',
              purchase: PurchaseSerializer.new(@purchase)
            }, status: :created
          else
            render json: { errors: @purchase.errors }, status: :unprocessable_entity
          end
        end
      rescue ActiveRecord::RecordNotFound => e
        render json: { error: "Asset not found: #{e.message}" }, status: :not_found
      end

      def download
        if @purchase.customer == current_user && @purchase.completed?
          # Implement file download logic here
          render json: { download_url: @purchase.asset.file_url }
        else
          render json: { error: 'Unauthorized' }, status: :unauthorized
        end
      end

      private

      def set_purchase
        @purchase = Purchase.find(params[:id])
      end

      def purchase_params
        params.permit(:asset_id, asset_ids: [])
      end

      def ensure_customer
        unless current_user.customer?
          render json: { error: 'Only customers can make purchases' }, 
                 status: :forbidden
        end
      end
    end
  end
end
