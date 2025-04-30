class Asset < ApplicationRecord
  include ErrorHandler

  # Relationships
  belongs_to :creator, class_name: 'User'
  has_many :purchases, dependent: :restrict_with_error
  has_many :customers, through: :purchases

  validates :title, presence: true, 
                   length: { minimum: 3, maximum: 100 }
  validates :description, length: { maximum: 1000 }
  validates :file_url, presence: true, 
                      format: { with: URI::DEFAULT_PARSER.make_regexp }
  validates :price, presence: true, 
                   numericality: { greater_than_or_equal_to: 0 }

  scope :available, -> { where(active: true) }
  scope :by_creator, ->(creator_id) { where(creator_id: creator_id) }
  scope :price_range, ->(min, max) { where(price: min..max) }
  scope :recent, -> { order(created_at: :desc) }

  def total_sales
    purchases.completed.sum(:amount)
  end

  def purchased_by?(user)
    purchases.completed.exists?(customer: user)
  end

  def can_be_purchased_by?(user)
    user.present? && 
    user.customer? && 
    !purchased_by?(user) && 
    user.id != creator_id
  end

  def self.bulk_import(creator, assets_data)
    transaction do
      assets_data.map do |asset_data|
        creator.created_assets.create!(
          title: asset_data['title'],
          description: asset_data['description'],
          file_url: asset_data['file_url'],
          price: asset_data['price']
        )
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    false
  end
end
