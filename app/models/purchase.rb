class Purchase < ApplicationRecord
  include ErrorHandler

  belongs_to :customer, class_name: 'User'
  belongs_to :asset

  validates :amount, presence: true, 
                    numericality: { greater_than: 0 }
  validates :status, presence: true, 
                    inclusion: { in: %w[pending completed failed] }
  validate :customer_can_purchase_asset

  scope :completed, -> { where(status: 'completed') }
  scope :pending, -> { where(status: 'pending') }
  scope :failed, -> { where(status: 'failed') }
  scope :recent, -> { order(created_at: :desc) }

  before_validation :set_amount, on: :create
  after_create :process_purchase

  def complete!
    update(status: 'completed')
  end

  def fail!
    update(status: 'failed')
  end

  def completed?
    status == 'completed'
  end

  def pending?
    status == 'pending'
  end

  def failed?
    status == 'failed'
  end

  private

  def set_amount
    self.amount = asset.price if amount.nil?
  end

  def customer_can_purchase_asset
    return if asset&.can_be_purchased_by?(customer)

    errors.add(:base, 'You cannot purchase this asset')
  end

  def process_purchase
    complete!
  rescue StandardError => e
    fail!
    Rails.logger.error("Purchase processing failed: #{e.message}")
  end
end
