class CreatorEarningsSerializer < ActiveModel::Serializer
  attributes :creator_id, :username, :total_earnings, :assets_count, 
             :total_sales

  def assets_count
    object.created_assets.count
  end

  def total_sales
    object.created_assets.joins(:purchases)
          .where(purchases: { status: 'completed' })
          .count
  end
end
