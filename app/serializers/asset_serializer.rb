class AssetSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :file_url, :price, 
             :created_at, :updated_at, :asset_stats

  belongs_to :creator, serializer: UserSimpleSerializer

  def asset_stats
    {
      total_sales: object.purchases.completed.count,
      total_revenue: object.purchases.completed.sum(:amount)
    }
  end

  def file_url
    if scope&.admin? || 
       scope == object.creator || 
       object.purchased_by?(scope)
      object.file_url
    else
      nil
    end
  end
end
