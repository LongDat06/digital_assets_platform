class PurchaseSimpleSerializer < ActiveModel::Serializer
  attributes :id, :amount, :status, :created_at
end
