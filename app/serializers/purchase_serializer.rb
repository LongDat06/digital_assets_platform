class PurchaseSerializer < ActiveModel::Serializer
  attributes :id, :amount, :title, :status, :created_at, :updated_at

  def title
    object.asset.title
  end

  def download_url
    if object.completed? && scope == object.customer
      object.asset.file_url
    end
  end
end
