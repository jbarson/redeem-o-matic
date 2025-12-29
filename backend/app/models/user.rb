class User < ApplicationRecord
  has_many :redemptions, dependent: :destroy

  validates :email, presence: true,
                    uniqueness: true,
                    format: { with: URI::MailTo::EMAIL_REGEXP, message: 'must be a valid email address' }
  validates :name, presence: true
  validates :points_balance, numericality: { greater_than_or_equal_to: 0 }
end
