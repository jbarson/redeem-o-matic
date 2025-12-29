import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { useUser } from '../context/UserContext';
import { userApi } from '../services/api';
import { logger } from '../services/logger';
import PointsBalance from '../components/user/PointsBalance';
import '../styles/Dashboard.css';

const Dashboard: React.FC = () => {
  const { user } = useUser();
  const [totalRedemptions, setTotalRedemptions] = useState<number>(0);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let isMounted = true;
    const controller = new AbortController();

    const fetchStats = async () => {
      if (user) {
        try {
          const history = await userApi.getRedemptions(user.id, { limit: 1 });
          if (isMounted) {
            setTotalRedemptions(history.total_count);
          }
        } catch (error: unknown) {
          if (isMounted) {
            logger.apiError(`/users/${user.id}/redemptions`, error);
          }
        } finally {
          if (isMounted) {
            setLoading(false);
          }
        }
      }
    };

    fetchStats();

    return () => {
      isMounted = false;
      controller.abort();
    };
  }, [user]);

  return (
    <div className="page-container">
      <h1>Welcome back, {user?.name}!</h1>

      <div className="dashboard-grid">
        <PointsBalance />

        <div className="stats-card">
          <div className="stat-label">Total Redemptions</div>
          <div className="stat-value">{loading ? '...' : totalRedemptions}</div>
        </div>
      </div>

      <div className="quick-actions">
        <Link to="/rewards" className="action-card">
          <h3>Browse Rewards</h3>
          <p>Discover and redeem available rewards</p>
        </Link>

        <Link to="/history" className="action-card">
          <h3>View History</h3>
          <p>See your past redemptions</p>
        </Link>
      </div>
    </div>
  );
};

export default Dashboard;
