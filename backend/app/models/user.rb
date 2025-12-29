class User < ApplicationRecord
  has_many :redemptions, dependent: :destroy

  validates :email, presence: true, uniqueness: true
  validates :name, presence: true
  validates :points_balance, numericality: { greater_than_or_equal_to: 0 }
end
