import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import axios from 'axios';
import { useUser } from '../context/UserContext';
import { userApi } from '../services/api';
import { User } from '../types';
import { logger } from '../services/logger';
import '../styles/LoginPage.css';

const LoginPage: React.FC = () => {
  const [users, setUsers] = useState<User[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const { login } = useUser();
  const navigate = useNavigate();

  useEffect(() => {
    let isMounted = true;
    const controller = new AbortController();

    const fetchUsers = async () => {
      try {
        const fetchedUsers = await userApi.getAll(controller.signal);
        if (isMounted) {
          setUsers(fetchedUsers);
        }
      } catch (err: unknown) {
        // Ignore abort errors
        if (axios.isCancel && axios.isCancel(err)) {
          return;
        }
        if (err instanceof Error && (err.name === 'CanceledError' || (err as any).code === 'ERR_CANCELED')) {
          return;
        }
        if (isMounted) {
          setError('Failed to load users. Please try again.');
          logger.apiError('/users', err);
        }
      } finally {
        if (isMounted) {
          setLoading(false);
        }
      }
    };

    fetchUsers();

    return () => {
      isMounted = false;
      controller.abort();
    };
  }, []);

  const handleUserSelect = async (user: User) => {
    try {
      logger.userAction('User Login Attempt', {
        userId: user.id,
        userName: user.name,
      });
      await login(user.id);
      logger.userAction('User Login Success', {
        userId: user.id,
        userName: user.name,
      });
      navigate('/');
    } catch (err: unknown) {
      setError('Failed to login. Please try again.');
      logger.apiError('/auth/login', err, { userId: user.id });
    }
  };

  if (loading) {
    return (
      <div className="login-page">
        <div className="login-container">
          <h1>Loading...</h1>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="login-page">
        <div className="login-container">
          <h1>Error</h1>
          <p className="error-message">{error}</p>
        </div>
      </div>
    );
  }

  return (
    <div className="login-page">
      <div className="login-container">
        <h1>Redeem-O-Matic</h1>
        <p className="subtitle">Select a user to continue</p>

        <div className="users-list">
          {users.map((user) => (
            <div
              key={user.id}
              className="user-card"
              onClick={() => handleUserSelect(user)}
            >
              <div className="user-info">
                <h3>{user.name}</h3>
                <p className="user-email">{user.email}</p>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};

export default LoginPage;
