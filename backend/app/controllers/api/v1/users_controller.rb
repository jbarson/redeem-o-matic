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
      id: current_user.id,
      name: current_user.name,
      email: current_user.email,
      points_balance: current_user.points_balance
    }
  end

  # GET /api/v1/users/:id/redemptions
  def redemptions
    # Ensure current_user is set (should be set by authenticate_user! but check anyway)
    unless current_user
      render json: { error: 'Unauthorized' }, status: :unauthorized
      return
    end

    # Users can only access their own redemptions
    # Convert both to integers for reliable comparison
    requested_user_id = params[:id].to_i
    unless current_user.id == requested_user_id
      render json: { error: 'Forbidden - You can only access your own data' }, status: :forbidden
      return
    end

    # Validate and sanitize pagination parameters
    limit = validate_pagination_limit(params[:limit])
    offset = validate_pagination_offset(params[:offset])

    user_redemptions = current_user.redemptions
                                   .includes(:reward)
                                   .order(created_at: :desc)
                                   .limit(limit)
                                   .offset(offset)

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
  rescue => e
    Rails.logger.error("Error fetching redemptions: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
    render json: { error: 'An error occurred while fetching redemption history' }, status: :internal_server_error
  end

  private

  # Validate and sanitize limit parameter
  # Returns a value between 1 and 100, defaulting to 50
  def validate_pagination_limit(limit_param)
    return 50 if limit_param.blank?

    begin
      limit = Integer(limit_param)
      # Clamp between 1 and 100
      limit.clamp(1, 100)
    rescue ArgumentError, TypeError
      # Invalid input, return default
      50
    end
  end

  # Validate and sanitize offset parameter
  # Returns a non-negative integer, defaulting to 0
  def validate_pagination_offset(offset_param)
    return 0 if offset_param.blank?

    begin
      offset = Integer(offset_param)
      # Ensure non-negative
      [offset, 0].max
    rescue ArgumentError, TypeError
      # Invalid input, return default
      0
    end
  end
end
