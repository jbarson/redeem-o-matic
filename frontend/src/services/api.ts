import axios, { AxiosError, InternalAxiosRequestConfig } from 'axios';
import { User, Reward, Redemption, RedemptionResponse, RedemptionsHistoryResponse } from '../types';
import { logger } from './logger';

// Use environment variable or fallback to localhost for development
const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:3000/api/v1';

const apiClient = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Add request interceptor to include auth token
apiClient.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('auth_token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Add response interceptor for consistent error handling
apiClient.interceptors.response.use(
  (response) => {
    return response;
  },
  (error: AxiosError) => {
    // Handle network errors
    if (!error.response) {
      logger.apiError(error.config?.url || 'unknown', error, {
        message: 'Network error - unable to reach server',
      });
      return Promise.reject(error);
    }

    const status = error.response.status;
    const endpoint = error.config?.url || 'unknown';

    // Handle 401 Unauthorized - clear auth and redirect to login
    // Don't redirect if we're already on the login page or if it's a login request
    if (status === 401 && !endpoint.includes('/auth/login') && window.location.pathname !== '/login') {
      logger.apiError(endpoint, error, {
        message: 'Authentication failed',
        status,
      });
      // Clear auth data
      localStorage.removeItem('auth_token');
      localStorage.removeItem('user');
      // Redirect to login
      window.location.href = '/login';
    } else {
      // Log other errors
      logger.apiError(endpoint, error, {
        status,
        data: error.response.data,
      });
    }

    // Return error with consistent structure
    return Promise.reject(error);
  }
);

export const authApi = {
  login: async (userId: number, signal?: AbortSignal): Promise<{ token: string; user: User }> => {
    const response = await apiClient.post('/auth/login', { user_id: userId }, { signal });
    return response.data;
  },
};

export const userApi = {
  getAll: async (signal?: AbortSignal): Promise<User[]> => {
    const response = await apiClient.get('/users', { signal });
    return response.data.users;
  },

  getBalance: async (id: number, signal?: AbortSignal): Promise<User> => {
    const response = await apiClient.get(`/users/${id}/balance`, { signal });
    return response.data;
  },

  getRedemptions: async (
    userId: number,
    params?: { limit?: number; offset?: number },
    signal?: AbortSignal
  ): Promise<RedemptionsHistoryResponse> => {
    const response = await apiClient.get(`/users/${userId}/redemptions`, { params, signal });
    return response.data;
  },
};

export const rewardsApi = {
  getAll: async (signal?: AbortSignal): Promise<Reward[]> => {
    const response = await apiClient.get('/rewards', { signal });
    return response.data.rewards;
  },
};

export const redemptionsApi = {
  create: async (rewardId: number, signal?: AbortSignal): Promise<RedemptionResponse> => {
    const response = await apiClient.post('/redemptions', {
      reward_id: rewardId,
    }, { signal });
    return response.data;
  },
};
