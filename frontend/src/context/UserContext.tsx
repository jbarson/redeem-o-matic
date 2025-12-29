import React, { createContext, useState, useContext, useCallback, ReactNode } from 'react';
import { User } from '../types';
import { userApi, authApi } from '../services/api';
import { logger } from '../services/logger';

interface UserContextType {
  user: User | null;
  login: (userId: number) => Promise<void>;
  logout: () => void;
  refreshBalance: () => Promise<void>;
}

const UserContext = createContext<UserContextType | undefined>(undefined);

export const UserProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
  const [user, setUser] = useState<User | null>(() => {
    const storedUser = localStorage.getItem('user');
    const storedToken = localStorage.getItem('auth_token');
    // Only restore user if token exists and user has valid structure
    if (storedUser && storedToken) {
      try {
        const parsedUser = JSON.parse(storedUser);
        // Validate that the user object has required fields
        if (parsedUser && typeof parsedUser.id === 'number') {
          return parsedUser;
        } else {
          // Invalid user data, clear it
          localStorage.removeItem('user');
          localStorage.removeItem('auth_token');
          return null;
        }
      } catch (e) {
        // Invalid JSON, clear it
        localStorage.removeItem('user');
        localStorage.removeItem('auth_token');
        return null;
      }
    }
    return null;
  });

  const login = useCallback(async (userId: number) => {
    try {
      const { token, user: loggedInUser } = await authApi.login(userId);
      localStorage.setItem('auth_token', token);
      localStorage.setItem('user', JSON.stringify(loggedInUser));
      setUser(loggedInUser);
    } catch (error: unknown) {
      logger.apiError('/auth/login', error, { userId });
      throw error;
    }
  }, []);

  const logout = useCallback(() => {
    setUser(null);
    localStorage.removeItem('user');
    localStorage.removeItem('auth_token');
  }, []);

  const refreshBalance = useCallback(async () => {
    if (user && user.id) {
      try {
        const updatedUser = await userApi.getBalance(user.id);
        // Ensure the updated user has all required fields
        if (updatedUser && typeof updatedUser.id === 'number') {
          setUser(updatedUser);
          localStorage.setItem('user', JSON.stringify(updatedUser));
        }
      } catch (error: unknown) {
        logger.apiError(`/users/${user.id}/balance`, error, { userId: user.id });
      }
    }
  }, [user]);

  return (
    <UserContext.Provider value={{ user, login, logout, refreshBalance }}>
      {children}
    </UserContext.Provider>
  );
};

export const useUser = (): UserContextType => {
  const context = useContext(UserContext);
  if (!context) {
    throw new Error('useUser must be used within a UserProvider');
  }
  return context;
};
