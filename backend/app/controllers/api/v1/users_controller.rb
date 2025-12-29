class Api::V1::UsersController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index]

  # GET /api/v1/users (public - for login selection, minimal info only)
  def index
    users = User.all
    render json: { users: users.as_json(only: [:id, :name]) }
  end

  # GET /api/v1/users/:id/balance
  def balance
    # Users can only access their own balance
    unless current_user.id == params[:id].to_i
      render json: { error: 'Forbidden - You can only access your own data' }, status: :forbidden
      return
    end

    render json: {
      user_id: current_user.id,
      name: current_user.name,
      email: current_user.email,
      points_balance: current_user.points_balance
    }
  end

  # GET /api/v1/users/:id/redemptions
  def redemptions
    # Users can only access their own redemptions
    unless current_user.id == params[:id].to_i
      render json: { error: 'Forbidden - You can only access your own data' }, status: :forbidden
      return
    end

    user_redemptions = current_user.redemptions
                                   .includes(:reward)
                                   .order(created_at: :desc)
                                   .limit(params[:limit] || 50)
                                   .offset(params[:offset] || 0)

    render json: {
      redemptions: user_redemptions.as_json(
        only: [:id, :points_spent, :status, :created_at],
        include: {
          reward: { only: [:id, :name, :image_url, :category] }
        }
      ),
      total_count: current_user.redemptions.count,
      current_balance: current_user.points_balance
    }
  end
end
