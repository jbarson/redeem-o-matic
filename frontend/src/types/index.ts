// TypeScript interfaces for the Redeem-O-Matic application

export interface User {
  id: number;
  email: string;
  name: string;
  points_balance: number;
}

export interface Reward {
  id: number;
  name: string;
  description: string;
  cost: number;
  image_url?: string;
  category: string;
  stock_quantity?: number;
  active: boolean;
}

export interface Redemption {
  id: number;
  user_id: number;
  reward_id: number;
  points_spent: number;
  status: string;
  created_at: string;
  reward: Reward;
}

export interface ApiResponse<T> {
  data: T;
  error?: string;
}

export interface RedemptionResponse {
  redemption: Redemption;
  new_balance: number;
}

export interface RedemptionsHistoryResponse {
  redemptions: Redemption[];
  total_count: number;
  current_balance: number;
}

// Error handling types
export interface ApiErrorResponse {
  error: string;
  required?: number;
  available?: number;
}

export interface ApiError {
  response?: {
    data?: ApiErrorResponse;
    status?: number;
  };
  message?: string;
}

export function isApiError(error: unknown): error is ApiError {
  return (
    typeof error === 'object' &&
    error !== null &&
    'response' in error
  );
}

export function getErrorMessage(error: unknown, defaultMessage: string): string {
  if (isApiError(error)) {
    return error.response?.data?.error || defaultMessage;
  }
  if (error instanceof Error) {
    return error.message;
  }
  return defaultMessage;
}
