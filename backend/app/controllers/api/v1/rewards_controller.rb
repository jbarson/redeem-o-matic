class Api::V1::RewardsController < ApplicationController
  # GET /api/v1/rewards
  def index
    rewards = Reward.active.order(:cost)
    render json: {
      rewards: rewards.as_json(only: [:id, :name, :description, :cost, :image_url, :category, :stock_quantity, :active])
    }
  end
end
