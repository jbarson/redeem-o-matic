class AddIndexesToOptimizeQueries < ActiveRecord::Migration[8.0]
  def change
    # Add index on rewards.active for filtering active rewards
    # This optimizes the GET /api/v1/rewards endpoint which filters by active status
    add_index :rewards, :active, name: 'index_rewards_on_active'

    # Add compound index for user redemptions ordered by date
    # This optimizes queries like: Redemption.where(user_id: X).order(created_at: :desc)
    # Used by GET /api/v1/users/:id/redemptions endpoint
    add_index :redemptions, [:user_id, :created_at], name: 'index_redemptions_on_user_and_date'
  end
end
