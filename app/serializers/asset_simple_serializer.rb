class AssetSimpleSerializer < ActiveModel::Serializer
  attributes :id, :title, :price
  
  belongs_to :creator, serializer: UserSimpleSerializer
end
