import axios from 'axios';
import { User, Reward, Redemption, RedemptionResponse, RedemptionsHistoryResponse } from '../types';

// Use environment variable or fallback to localhost for development
const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:3000/api/v1';

const apiClient = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

export const userApi = {
  getAll: async (): Promise<User[]> => {
    const response = await apiClient.get('/users');
    return response.data.users;
  },

  getBalance: async (id: number): Promise<User> => {
    const response = await apiClient.get(`/users/${id}/balance`);
    return response.data;
  },

  getRedemptions: async (
    userId: number,
    params?: { limit?: number; offset?: number }
  ): Promise<RedemptionsHistoryResponse> => {
    const response = await apiClient.get(`/users/${userId}/redemptions`, { params });
    return response.data;
  },
};

export const rewardsApi = {
  getAll: async (): Promise<Reward[]> => {
    const response = await apiClient.get('/rewards');
    return response.data.rewards;
  },
};

export const redemptionsApi = {
  create: async (userId: number, rewardId: number): Promise<RedemptionResponse> => {
    const response = await apiClient.post('/redemptions', {
      user_id: userId,
      reward_id: rewardId,
    });
    return response.data;
  },
};
