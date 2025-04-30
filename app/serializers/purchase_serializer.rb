class PurchaseSerializer < ActiveModel::Serializer
  attributes :id, :amount, :status, :created_at, :updated_at

  belongs_to :customer, serializer: UserSimpleSerializer
  belongs_to :asset, serializer: AssetSimpleSerializer

  def download_url
    if object.completed? && scope == object.customer
      object.asset.file_url
    end
  end
end
