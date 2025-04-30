class User < ApplicationRecord
	include ErrorHandler
	has_secure_password

  has_many :created_assets, class_name: 'Asset', foreign_key: 'creator_id'
  has_many :purchases, foreign_key: 'customer_id'
  has_many :purchased_assets, through: :purchases, source: :asset

  validates :email, presence: true, 
                   uniqueness: { case_sensitive: false },
                   format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :username, presence: true, 
                      uniqueness: { case_sensitive: false },
                      length: { minimum: 3, maximum: 30 }
  validates :password, presence: true, 
                      length: { minimum: 6 }, 
                      if: :password_required?
  validates :role, presence: true, 
                  inclusion: { in: %w[creator customer admin] }

  before_save :downcase_email
  before_validation :set_default_role, on: :create

  def creator?
    role == 'creator'
  end

  def customer?
    role == 'customer'
  end

  def admin?
    role == 'admin'
  end

  def total_earnings
    return 0 unless creator?
    created_assets.joins(:purchases)
                 .where(purchases: { status: 'completed' })
                 .sum('purchases.amount')
  end

  private

  def password_required?
    new_record? || password.present?
  end

  def downcase_email
    self.email = email.downcase if email.present?
  end

  def set_default_role
    self.role ||= 'customer'
  end
end
