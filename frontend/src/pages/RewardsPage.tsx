import React, { useState, useEffect, useRef } from 'react';
import axios from 'axios';
import { useUser } from '../context/UserContext';
import { rewardsApi, redemptionsApi } from '../services/api';
import { Reward, getErrorMessage } from '../types';
import { logger } from '../services/logger';
import RewardCard from '../components/rewards/RewardCard';
import ConfirmModal from '../components/common/ConfirmModal';
import '../styles/RewardsPage.css';

const RewardsPage: React.FC = () => {
  const { user, refreshBalance } = useUser();
  const [rewards, setRewards] = useState<Reward[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [selectedReward, setSelectedReward] = useState<Reward | null>(null);
  const [redeeming, setRedeeming] = useState(false);
  const [successMessage, setSuccessMessage] = useState<string | null>(null);
  const timeoutRef = useRef<NodeJS.Timeout | null>(null);
  const isMountedRef = useRef(true);

  useEffect(() => {
    isMountedRef.current = true;
    const controller = new AbortController();

    const fetchRewards = async () => {
      try {
        const fetchedRewards = await rewardsApi.getAll(controller.signal);
        if (isMountedRef.current) {
          setRewards(fetchedRewards);
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
        if (isMountedRef.current) {
          const errorMessage = getErrorMessage(err, 'Failed to load rewards. Please try again.');
          setError(errorMessage);
          logger.apiError('/rewards', err);
        }
      } finally {
        if (isMountedRef.current) {
          setLoading(false);
        }
      }
    };

    fetchRewards();

    return () => {
      isMountedRef.current = false;
      controller.abort();
    };
  }, []);

  // Cleanup timeout on unmount or when successMessage changes
  useEffect(() => {
    if (successMessage) {
      // Clear any existing timeout
      if (timeoutRef.current) {
        clearTimeout(timeoutRef.current);
      }
      // Set new timeout
      timeoutRef.current = setTimeout(() => {
        if (isMountedRef.current) {
          setSuccessMessage(null);
        }
      }, 5000);
    }

    return () => {
      if (timeoutRef.current) {
        clearTimeout(timeoutRef.current);
      }
    };
  }, [successMessage]);

  const handleRedeemClick = (reward: Reward) => {
    setSelectedReward(reward);
    setError(null);
    setSuccessMessage(null);
  };

  const handleConfirmRedemption = async () => {
    if (!selectedReward || !user) return;

    setRedeeming(true);
    setError(null);

    try {
      await redemptionsApi.create(selectedReward.id);
      await refreshBalance();

      // Log successful redemption
      logger.userAction('Reward Redeemed', {
        rewardId: selectedReward.id,
        rewardName: selectedReward.name,
        cost: selectedReward.cost,
        userId: user.id,
      });

      setSuccessMessage(`Successfully redeemed ${selectedReward.name}!`);
      setSelectedReward(null);

      // Refresh rewards list to update stock
      const updatedRewards = await rewardsApi.getAll();
      if (isMountedRef.current) {
        setRewards(updatedRewards);
      }
    } catch (err: unknown) {
      const errorMessage = getErrorMessage(err, 'Failed to redeem reward. Please try again.');
      setError(errorMessage);
      logger.apiError('/redemptions', err, {
        rewardId: selectedReward.id,
        userId: user.id,
      });
      setSelectedReward(null);
    } finally {
      setRedeeming(false);
    }
  };

  const handleCancelRedemption = () => {
    setSelectedReward(null);
  };

  if (loading) {
    return (
      <div className="page-container">
        <h1>Loading rewards...</h1>
      </div>
    );
  }

  return (
    <div className="page-container">
      <h1>Available Rewards</h1>

      {error && <div className="error-banner">{error}</div>}
      {successMessage && <div className="success-banner">{successMessage}</div>}

      <div className="rewards-grid">
        {rewards.map((reward) => (
          <RewardCard
            key={reward.id}
            reward={reward}
            userBalance={user?.points_balance || 0}
            onRedeem={handleRedeemClick}
          />
        ))}
      </div>

      {rewards.length === 0 && !loading && (
        <div className="empty-state">
          <p>No rewards available at the moment.</p>
        </div>
      )}

      {selectedReward && user && (
        <ConfirmModal
          reward={selectedReward}
          userBalance={user.points_balance}
          onConfirm={handleConfirmRedemption}
          onCancel={handleCancelRedemption}
        />
      )}

      {redeeming && (
        <div className="loading-overlay">
          <div className="loading-spinner">Processing redemption...</div>
        </div>
      )}
    </div>
  );
};

export default RewardsPage;
