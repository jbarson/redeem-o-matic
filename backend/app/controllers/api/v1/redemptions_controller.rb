class Api::V1::RedemptionsController < ApplicationController
  # POST /api/v1/redemptions
  def create
    redemption = nil
    new_balance = nil

    # Execute redemption in a transaction with pessimistic locking
    ActiveRecord::Base.transaction do
      # Lock records for update to prevent race conditions
      # This acquires FOR UPDATE locks in the database
      user = User.lock.find(params[:user_id])
      reward = Reward.lock.find(params[:reward_id])

      # Validate reward is active (inside transaction after lock)
      unless reward.active
        raise ActiveRecord::RecordInvalid.new(reward), 'Reward is not available'
      end

      # Check stock availability (inside transaction after lock)
      if reward.stock_quantity && reward.stock_quantity <= 0
        raise ActiveRecord::RecordInvalid.new(reward), 'Reward is out of stock'
      end

      # Check user has sufficient points (inside transaction after lock)
      if user.points_balance < reward.cost
        raise ActiveRecord::RecordInvalid.new(user), "Insufficient points. Required: #{reward.cost}, Available: #{user.points_balance}"
      end

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
