class Api::V1::RedemptionsController < ApplicationController
  # POST /api/v1/redemptions
  def create
    user = User.find(params[:user_id])
    reward = Reward.find(params[:reward_id])

    # Validate reward is active
    unless reward.active
      return render json: { error: 'Reward is not available' }, status: :unprocessable_entity
    end

    # Check stock availability
    if reward.stock_quantity && reward.stock_quantity <= 0
      return render json: { error: 'Reward is out of stock' }, status: :unprocessable_entity
    end

    # Check user has sufficient points
    if user.points_balance < reward.cost
      return render json: {
        error: 'Insufficient points',
        required: reward.cost,
        available: user.points_balance
      }, status: :unprocessable_entity
    end

    # Execute redemption in a transaction
    redemption = nil
    new_balance = nil

    ActiveRecord::Base.transaction do
      # Create redemption
      redemption = Redemption.create!(
        user: user,
        reward: reward,
        points_spent: reward.cost,
        status: 'completed'
      )

      # Deduct points from user
      user.update!(points_balance: user.points_balance - reward.cost)

      # Decrement stock if tracked
      if reward.stock_quantity
        reward.update!(stock_quantity: reward.stock_quantity - 1)
      end

      new_balance = user.points_balance
    end

    render json: {
      redemption: redemption.as_json(
        only: [:id, :user_id, :reward_id, :points_spent, :status, :created_at],
        include: {
          reward: { only: [:name, :cost] }
        }
      ),
      new_balance: new_balance
    }, status: :created

  rescue ActiveRecord::RecordNotFound => e
    render json: { error: 'User or Reward not found' }, status: :not_found
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: :unprocessable_entity
  rescue => e
    render json: { error: 'An error occurred while processing the redemption' }, status: :internal_server_error
  end
end
