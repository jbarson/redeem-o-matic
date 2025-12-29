class Reward < ApplicationRecord
  has_many :redemptions, dependent: :destroy

  validates :name, presence: true
  validates :cost, presence: true, numericality: { greater_than: 0 }
  validates :stock_quantity, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  scope :active, -> { where(active: true) }
end
