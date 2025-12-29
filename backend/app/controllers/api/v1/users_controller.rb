class Api::V1::UsersController < ApplicationController
  before_action :set_user, only: [:balance, :redemptions]

  # GET /api/v1/users
  def index
    users = User.all
    render json: { users: users.as_json(only: [:id, :name, :email, :points_balance]) }
  end

  # GET /api/v1/users/:id/balance
  def balance
    render json: {
      user_id: @user.id,
      name: @user.name,
      email: @user.email,
      points_balance: @user.points_balance
    }
  end

  # GET /api/v1/users/:id/redemptions
  def redemptions
    user_redemptions = @user.redemptions
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
      total_count: @user.redemptions.count,
      current_balance: @user.points_balance
    }
  end

  private

  def set_user
    validate_user_id!
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'User not found' }, status: :not_found
  rescue ArgumentError => e
    render json: { error: e.message }, status: :bad_request
  end

  def validate_user_id!
    if params[:id].blank?
      raise ArgumentError, 'id is required'
    end

    begin
      Integer(params[:id])
    rescue ArgumentError, TypeError
      raise ArgumentError, 'id must be a valid number'
    end
  end
end
