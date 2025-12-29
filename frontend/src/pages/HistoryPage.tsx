import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { useUser } from '../context/UserContext';
import { userApi } from '../services/api';
import { Redemption, getErrorMessage } from '../types';
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
    let isMounted = true;
    const controller = new AbortController();

    const fetchHistory = async () => {
      if (!user) {
        if (isMounted) {
          setLoading(false);
          setError('Please log in to view your redemption history.');
        }
        return;
      }

      if (!user.id) {
        if (isMounted) {
          setLoading(false);
          setError('Invalid user data. Please log in again.');
          logger.error('User object missing id property', undefined, { user });
        }
        return;
      }

      try {
        const history = await userApi.getRedemptions(user.id, undefined, controller.signal);
        if (isMounted) {
          setRedemptions(history.redemptions);
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
          const errorMessage = getErrorMessage(err, 'Failed to load redemption history. Please try again.');
          setError(errorMessage);
          logger.apiError(`/users/${user.id}/redemptions`, err);
        }
      } finally {
        if (isMounted) {
          setLoading(false);
        }
      }
    };

    fetchHistory();

    return () => {
      isMounted = false;
      controller.abort();
    };
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
