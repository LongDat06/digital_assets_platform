class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :username, :role, :created_at, :profile_data

  has_many :created_assets, if: :creator?
  has_many :purchases, if: :customer?

  def profile_data
    {
      total_assets: creator? ? object.created_assets.count : nil,
      total_purchases: customer? ? object.purchases.count : nil,
      total_earnings: creator? ? object.total_earnings : nil
    }.compact
  end

  def creator?
    object.role == 'creator'
  end

  def customer?
    object.role == 'customer'
  end
end
