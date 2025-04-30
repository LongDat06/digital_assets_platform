module Api
  module V1
    class AdminController < BaseController
      before_action :ensure_admin

      def creator_earnings
        creators = User.where(role: 'creator')
                      .joins(created_assets: :purchases)
                      .where(purchases: { status: 'completed' })
                      .select('users.id as creator_id, 
                              users.username, 
                              SUM(purchases.amount) as total_earnings')
                      .group('users.id, users.username')

        render json: creators
      end

      def platform_statistics
        stats = {
          total_users: User.count,
          total_creators: User.where(role: 'creator').count,
          total_customers: User.where(role: 'customer').count,
          total_assets: Asset.count,
          total_sales: Purchase.completed.sum(:amount),
          recent_purchases: Purchase.completed.recent.limit(10)
        }

        render json: stats
      end

      private

      def ensure_admin
        unless current_user.admin?
          render json: { error: 'Admin access required' }, 
                 status: :forbidden
        end
      end
    end
  end
end
