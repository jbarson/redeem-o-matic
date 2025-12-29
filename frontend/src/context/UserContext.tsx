import React, { createContext, useState, useContext, useCallback, ReactNode } from 'react';
import { User } from '../types';
import { userApi } from '../services/api';
import { logger } from '../services/logger';

interface UserContextType {
  user: User | null;
  login: (user: User) => void;
  logout: () => void;
  refreshBalance: () => Promise<void>;
}

const UserContext = createContext<UserContextType | undefined>(undefined);

export const UserProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
  const [user, setUser] = useState<User | null>(() => {
    const storedUser = localStorage.getItem('user');
    return storedUser ? JSON.parse(storedUser) : null;
  });

  const login = useCallback((newUser: User) => {
    setUser(newUser);
    localStorage.setItem('user', JSON.stringify(newUser));
  }, []);

  const logout = useCallback(() => {
    setUser(null);
    localStorage.removeItem('user');
  }, []);

  const refreshBalance = useCallback(async () => {
    if (user) {
      try {
        const updatedUser = await userApi.getBalance(user.id);
        setUser(updatedUser);
        localStorage.setItem('user', JSON.stringify(updatedUser));
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
