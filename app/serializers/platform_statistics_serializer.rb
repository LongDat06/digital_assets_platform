class PlatformStatisticsSerializer < ActiveModel::Serializer
  attributes :total_users, :total_creators, :total_customers,
             :total_assets, :total_sales, :recent_activity

  def recent_activity
    object.recent_purchases.map do |purchase|
      {
        id: purchase.id,
        asset_title: purchase.asset.title,
        amount: purchase.amount,
        customer: purchase.customer.username,
        created_at: purchase.created_at
      }
    end
  end
end
