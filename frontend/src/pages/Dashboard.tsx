import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { useUser } from '../context/UserContext';
import { userApi } from '../services/api';
import PointsBalance from '../components/user/PointsBalance';
import '../styles/Dashboard.css';

const Dashboard: React.FC = () => {
  const { user } = useUser();
  const [totalRedemptions, setTotalRedemptions] = useState<number>(0);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchStats = async () => {
      if (user) {
        try {
          const history = await userApi.getRedemptions(user.id, { limit: 1 });
          setTotalRedemptions(history.total_count);
        } catch (error) {
          console.error('Failed to fetch stats:', error);
        } finally {
          setLoading(false);
        }
      }
    };

    fetchStats();
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
