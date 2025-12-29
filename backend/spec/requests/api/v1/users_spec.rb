require 'rails_helper'

RSpec.describe "Api::V1::Users", type: :request do
  let(:json_response) { JSON.parse(response.body) }

  describe "GET /api/v1/users" do
    it "returns all users (public endpoint, minimal info)" do
      users = create_list(:user, 3)

      get '/api/v1/users'

      expect(response).to have_http_status(:ok)
      expect(json_response['users'].size).to eq(3)
      # Index endpoint only returns id and name (for login selection)
      expect(json_response['users'].first).to include(
        'id' => users.first.id,
        'name' => users.first.name
      )
      expect(json_response['users'].first).not_to have_key('email')
      expect(json_response['users'].first).not_to have_key('points_balance')
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
      get "/api/v1/users/#{user.id}/balance", headers: auth_headers_for(user)

      expect(response).to have_http_status(:ok)
      expect(json_response).to include(
        'id' => user.id,
        'name' => user.name,
        'email' => user.email,
        'points_balance' => 1500
      )
    end

    it "returns 403 when trying to access another user's balance" do
      other_user = create(:user)
      get "/api/v1/users/#{other_user.id}/balance", headers: auth_headers_for(user)

      expect(response).to have_http_status(:forbidden)
      expect(json_response['error']).to include('You can only access your own data')
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
      get "/api/v1/users/#{user.id}/redemptions", headers: auth_headers_for(user)

      expect(response).to have_http_status(:ok)
      expect(json_response['redemptions'].size).to eq(3)
      expect(json_response['total_count']).to eq(3)
      expect(json_response['current_balance']).to eq(user.points_balance)
    end

    it "returns redemptions ordered by created_at DESC" do
      redemptions = user.redemptions.order(created_at: :desc)

      get "/api/v1/users/#{user.id}/redemptions", headers: auth_headers_for(user)

      expect(response).to have_http_status(:ok)
      expect(json_response['redemptions'].first['id']).to eq(redemptions.first.id)
    end

    it "includes reward details in each redemption" do
      get "/api/v1/users/#{user.id}/redemptions", headers: auth_headers_for(user)

      expect(response).to have_http_status(:ok)
      redemption = json_response['redemptions'].first
      expect(redemption['reward']).to be_present
      expect(redemption['reward']).to include('id', 'name', 'image_url')
    end

    it "returns empty array when user has no redemptions" do
      new_user = create(:user)

      get "/api/v1/users/#{new_user.id}/redemptions", headers: auth_headers_for(new_user)

      expect(response).to have_http_status(:ok)
      expect(json_response['redemptions']).to eq([])
      expect(json_response['total_count']).to eq(0)
    end

    it "returns 403 when trying to access another user's redemptions" do
      other_user = create(:user)
      get "/api/v1/users/#{other_user.id}/redemptions", headers: auth_headers_for(user)

      expect(response).to have_http_status(:forbidden)
      expect(json_response['error']).to include('You can only access your own data')
    end
  end
end
