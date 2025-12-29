require 'rails_helper'

RSpec.describe "Api::V1::Auth", type: :request do
  let(:json_response) { JSON.parse(response.body) }

  describe "POST /api/v1/auth/login" do
    let(:user) { create(:user, name: 'Test User', email: 'test@example.com', points_balance: 1000) }

    context "with valid user_id" do
      it "returns a JWT token and user data" do
        post '/api/v1/auth/login', params: { user_id: user.id }

        expect(response).to have_http_status(:ok)
        expect(json_response).to have_key('token')
        expect(json_response).to have_key('user')
        expect(json_response['user']).to include(
          'id' => user.id,
          'name' => 'Test User',
          'email' => 'test@example.com',
          'points_balance' => 1000
        )
        expect(json_response['token']).to be_a(String)
        expect(json_response['token'].split('.').length).to eq(3) # JWT has 3 parts
      end

      it "generates a valid JWT token that can be decoded" do
        post '/api/v1/auth/login', params: { user_id: user.id }

        expect(response).to have_http_status(:ok)
        token = json_response['token']
        
        # Decode the token to verify it's valid
        secret_key = Rails.application.credentials.secret_key_base || Rails.application.secret_key_base
        decoded = JWT.decode(token, secret_key, true, algorithm: 'HS256')
        expect(decoded[0]['user_id']).to eq(user.id)
        expect(decoded[0]).to have_key('exp')
      end
    end

    context "with missing user_id" do
      it "returns 400 error" do
        post '/api/v1/auth/login', params: {}

        expect(response).to have_http_status(:bad_request)
        expect(json_response['error']).to eq('user_id is required')
      end
    end

    context "with non-existent user_id" do
      it "returns 404 error" do
        post '/api/v1/auth/login', params: { user_id: 999 }

        expect(response).to have_http_status(:not_found)
        expect(json_response['error']).to eq('User not found')
      end
    end

    context "without authentication requirement" do
      it "allows access without JWT token" do
        post '/api/v1/auth/login', params: { user_id: user.id }

        expect(response).to have_http_status(:ok)
        expect(json_response).to have_key('token')
      end
    end
  end
end

