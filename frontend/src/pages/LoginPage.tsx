import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import axios from 'axios';
import { useUser } from '../context/UserContext';
import { userApi } from '../services/api';
import { User, getErrorMessage } from '../types';
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
        if (err instanceof Error && (err.name === 'CanceledError' || (err as any).code === 'ERR_CANCELED')) {
          return;
        }
        // Check for Axios cancel errors (if axios.isCancel function exists)
        if (typeof axios.isCancel === 'function' && axios.isCancel(err)) {
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
    // Clear any previous errors
    setError(null);
    
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
      const errorMessage = getErrorMessage(err, 'Failed to login. Please try again.');
      setError(errorMessage);
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

  return (
    <div className="login-page">
      <div className="login-container">
        <h1>Redeem-O-Matic</h1>
        <p className="subtitle">Select a user to continue</p>

        {error && (
          <div className="error-banner" style={{ marginBottom: '20px', padding: '10px', backgroundColor: '#fee', color: '#c33', borderRadius: '4px' }}>
            {error}
            <button 
              onClick={() => setError(null)} 
              style={{ marginLeft: '10px', padding: '4px 8px', cursor: 'pointer' }}
            >
              Dismiss
            </button>
          </div>
        )}

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
