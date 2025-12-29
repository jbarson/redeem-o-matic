require 'rails_helper'

RSpec.describe "Api::V1::Rewards", type: :request do
  let(:json_response) { JSON.parse(response.body) }

  describe "GET /api/v1/rewards" do
    it "returns all active rewards" do
      active_rewards = create_list(:reward, 3, active: true)
      inactive_reward = create(:reward, active: false)

      get '/api/v1/rewards'

      expect(response).to have_http_status(:ok)
      expect(json_response['rewards'].size).to eq(3)

      returned_ids = json_response['rewards'].map { |r| r['id'] }
      expect(returned_ids).to include(*active_rewards.map(&:id))
      expect(returned_ids).not_to include(inactive_reward.id)
    end

    it "returns rewards with all necessary attributes" do
      reward = create(:reward,
        name: 'Test Reward',
        description: 'Test Description',
        cost: 500,
        category: 'Gift Card',
        stock_quantity: 10,
        active: true
      )

      get '/api/v1/rewards'

      expect(response).to have_http_status(:ok)
      reward_json = json_response['rewards'].first
      expect(reward_json).to include(
        'id' => reward.id,
        'name' => 'Test Reward',
        'description' => 'Test Description',
        'cost' => 500,
        'category' => 'Gift Card',
        'stock_quantity' => 10,
        'active' => true
      )
    end

    it "returns an empty array when no active rewards exist" do
      create_list(:reward, 2, active: false)

      get '/api/v1/rewards'

      expect(response).to have_http_status(:ok)
      expect(json_response['rewards']).to eq([])
    end

    it "handles rewards with nil stock_quantity" do
      reward = create(:reward, stock_quantity: nil)

      get '/api/v1/rewards'

      expect(response).to have_http_status(:ok)
      reward_json = json_response['rewards'].first
      expect(reward_json['stock_quantity']).to be_nil
    end
  end
end
