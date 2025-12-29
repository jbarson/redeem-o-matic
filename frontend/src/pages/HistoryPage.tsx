import React, { useState, useEffect } from 'react';
import { useUser } from '../context/UserContext';
import { userApi } from '../services/api';
import { Redemption } from '../types';
import { logger } from '../services/logger';
import RedemptionHistory from '../components/redemptions/RedemptionHistory';
import PointsBalance from '../components/user/PointsBalance';
import '../styles/HistoryPage.css';

const HistoryPage: React.FC = () => {
  const { user } = useUser();
  const [redemptions, setRedemptions] = useState<Redemption[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchHistory = async () => {
      if (user) {
        try {
          const history = await userApi.getRedemptions(user.id);
          setRedemptions(history.redemptions);
        } catch (err: unknown) {
          setError('Failed to load redemption history. Please try again.');
          logger.apiError(`/users/${user.id}/redemptions`, err);
        } finally {
          setLoading(false);
        }
      }
    };

    fetchHistory();
  }, [user]);

  if (loading) {
    return (
      <div className="page-container">
        <h1>Loading history...</h1>
      </div>
    );
  }

  return (
    <div className="page-container">
      <div className="history-header">
        <h1>Redemption History</h1>
        <PointsBalance />
      </div>

      {error && <div className="error-banner">{error}</div>}

      <RedemptionHistory redemptions={redemptions} />
    </div>
  );
};

export default HistoryPage;
