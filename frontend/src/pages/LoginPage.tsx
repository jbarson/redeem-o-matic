import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
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
    const fetchUsers = async () => {
      try {
        const fetchedUsers = await userApi.getAll();
        setUsers(fetchedUsers);
      } catch (err: unknown) {
        setError('Failed to load users. Please try again.');
        logger.apiError('/users', err);
      } finally {
        setLoading(false);
      }
    };

    fetchUsers();
  }, []);

  const handleUserSelect = (user: User) => {
    logger.userAction('User Login', {
      userId: user.id,
      userName: user.name,
    });
    login(user);
    navigate('/');
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
