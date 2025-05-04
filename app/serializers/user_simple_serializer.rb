class UserSimpleSerializer < ActiveModel::Serializer
  attributes :id, :username, :role
end
