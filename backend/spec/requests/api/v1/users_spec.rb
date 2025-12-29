require 'rails_helper'

RSpec.describe "Api::V1::Users", type: :request do
  let(:json_response) { JSON.parse(response.body) }

  describe "GET /api/v1/users" do
    it "returns all users" do
      users = create_list(:user, 3)

      get '/api/v1/users'

      expect(response).to have_http_status(:ok)
      expect(json_response['users'].size).to eq(3)
      expect(json_response['users'].first).to include(
        'id' => users.first.id,
        'name' => users.first.name,
        'email' => users.first.email,
        'points_balance' => users.first.points_balance
      )
    end

    it "returns an empty array when no users exist" do
      get '/api/v1/users'

      expect(response).to have_http_status(:ok)
      expect(json_response['users']).to eq([])
    end
  end

  describe "GET /api/v1/users/:id/balance" do
    let(:user) { create(:user, points_balance: 1500) }

    it "returns the user's balance information" do
      get "/api/v1/users/#{user.id}/balance"

      expect(response).to have_http_status(:ok)
      expect(json_response).to include(
        'user_id' => user.id,
        'name' => user.name,
        'email' => user.email,
        'points_balance' => 1500
      )
    end

    it "returns 404 when user does not exist" do
      get "/api/v1/users/999/balance"

      expect(response).to have_http_status(:not_found)
      expect(json_response['error']).to eq('User not found')
    end
  end

  describe "GET /api/v1/users/:id/redemptions" do
    let(:user) { create(:user) }
    let(:rewards) { create_list(:reward, 3) }

    before do
      rewards.each do |reward|
        create(:redemption, user: user, reward: reward, points_spent: reward.cost)
      end
    end

    it "returns the user's redemption history" do
      get "/api/v1/users/#{user.id}/redemptions"

      expect(response).to have_http_status(:ok)
      expect(json_response['redemptions'].size).to eq(3)
      expect(json_response['total_count']).to eq(3)
      expect(json_response['current_balance']).to eq(user.points_balance)
    end

    it "returns redemptions ordered by created_at DESC" do
      redemptions = user.redemptions.order(created_at: :desc)

      get "/api/v1/users/#{user.id}/redemptions"

      expect(response).to have_http_status(:ok)
      expect(json_response['redemptions'].first['id']).to eq(redemptions.first.id)
    end

    it "includes reward details in each redemption" do
      get "/api/v1/users/#{user.id}/redemptions"

      expect(response).to have_http_status(:ok)
      redemption = json_response['redemptions'].first
      expect(redemption['reward']).to be_present
      expect(redemption['reward']).to include('id', 'name', 'image_url')
    end

    it "returns empty array when user has no redemptions" do
      new_user = create(:user)

      get "/api/v1/users/#{new_user.id}/redemptions"

      expect(response).to have_http_status(:ok)
      expect(json_response['redemptions']).to eq([])
      expect(json_response['total_count']).to eq(0)
    end

    it "returns 404 when user does not exist" do
      get "/api/v1/users/999/redemptions"

      expect(response).to have_http_status(:not_found)
      expect(json_response['error']).to eq('User not found')
    end
  end
end
