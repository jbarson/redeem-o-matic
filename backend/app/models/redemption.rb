class Redemption < ApplicationRecord
  belongs_to :user
  belongs_to :reward

  validates :user_id, presence: true
  validates :reward_id, presence: true
  validates :points_spent, presence: true, numericality: { greater_than: 0 }
  validates :status, inclusion: { in: %w[pending completed cancelled] }
end
