require 'rails_helper'

RSpec.describe "Api::V1::Redemptions", type: :request do
  let(:json_response) { JSON.parse(response.body) }

  describe "POST /api/v1/redemptions" do
    let(:user) { create(:user, points_balance: 1000) }
    let(:reward) { create(:reward, cost: 500, stock_quantity: 10) }

    context "with valid parameters" do
      it "creates a redemption and updates user balance" do
        expect {
          post '/api/v1/redemptions', params: { user_id: user.id, reward_id: reward.id }
        }.to change { Redemption.count }.by(1)

        expect(response).to have_http_status(:created)
        expect(json_response['new_balance']).to eq(500)
        expect(user.reload.points_balance).to eq(500)
      end

      it "decrements reward stock_quantity when present" do
        post '/api/v1/redemptions', params: { user_id: user.id, reward_id: reward.id }

        expect(response).to have_http_status(:created)
        expect(reward.reload.stock_quantity).to eq(9)
      end

      it "does not decrement stock_quantity when nil" do
        unlimited_reward = create(:reward, cost: 500, stock_quantity: nil)

        post '/api/v1/redemptions', params: { user_id: user.id, reward_id: unlimited_reward.id }

        expect(response).to have_http_status(:created)
        expect(unlimited_reward.reload.stock_quantity).to be_nil
      end

      it "returns the redemption details" do
        post '/api/v1/redemptions', params: { user_id: user.id, reward_id: reward.id }

        expect(response).to have_http_status(:created)
        redemption_json = json_response['redemption']
        expect(redemption_json).to include(
          'user_id' => user.id,
          'reward_id' => reward.id,
          'points_spent' => 500,
          'status' => 'completed'
        )
        expect(redemption_json['reward']).to be_present
      end
    end

    context "with insufficient points" do
      it "returns 422 error and does not create redemption" do
        user.update(points_balance: 100)

        expect {
          post '/api/v1/redemptions', params: { user_id: user.id, reward_id: reward.id }
        }.not_to change { Redemption.count }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['error']).to include('Insufficient points')
      end

      it "does not update user balance when insufficient points" do
        user.update(points_balance: 100)

        post '/api/v1/redemptions', params: { user_id: user.id, reward_id: reward.id }

        expect(user.reload.points_balance).to eq(100)
      end

      it "does not decrement stock when insufficient points" do
        user.update(points_balance: 100)
        initial_stock = reward.stock_quantity

        post '/api/v1/redemptions', params: { user_id: user.id, reward_id: reward.id }

        expect(reward.reload.stock_quantity).to eq(initial_stock)
      end
    end

    context "with out of stock reward" do
      it "returns 422 error when stock_quantity is 0" do
        reward.update(stock_quantity: 0)

        expect {
          post '/api/v1/redemptions', params: { user_id: user.id, reward_id: reward.id }
        }.not_to change { Redemption.count }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['error']).to include('out of stock')
      end

      it "does not update user balance when out of stock" do
        reward.update(stock_quantity: 0)

        post '/api/v1/redemptions', params: { user_id: user.id, reward_id: reward.id }

        expect(user.reload.points_balance).to eq(1000)
      end
    end

    context "with inactive reward" do
      it "returns 422 error when reward is inactive" do
        reward.update(active: false)

        expect {
          post '/api/v1/redemptions', params: { user_id: user.id, reward_id: reward.id }
        }.not_to change { Redemption.count }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['error']).to include('not available')
      end
    end

    context "with non-existent user" do
      it "returns 404 error" do
        post '/api/v1/redemptions', params: { user_id: 999, reward_id: reward.id }

        expect(response).to have_http_status(:not_found)
        expect(json_response['error']).to eq('User or Reward not found')
      end
    end

    context "with non-existent reward" do
      it "returns 404 error" do
        post '/api/v1/redemptions', params: { user_id: user.id, reward_id: 999 }

        expect(response).to have_http_status(:not_found)
        expect(json_response['error']).to eq('User or Reward not found')
      end
    end

    context "transaction safety" do
      it "rolls back all changes if an error occurs during transaction" do
        # Stub the user update to fail, simulating a transaction error
        allow_any_instance_of(User).to receive(:update!).and_raise(ActiveRecord::RecordInvalid.new(user))

        initial_user_balance = user.points_balance
        initial_stock = reward.stock_quantity

        post '/api/v1/redemptions', params: { user_id: user.id, reward_id: reward.id }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(user.reload.points_balance).to eq(initial_user_balance)
        expect(reward.reload.stock_quantity).to eq(initial_stock)
        expect(Redemption.count).to eq(0)
      end
    end
  end
end
