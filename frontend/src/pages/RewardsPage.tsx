import React, { useState, useEffect } from 'react';
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

  useEffect(() => {
    const fetchRewards = async () => {
      try {
        const fetchedRewards = await rewardsApi.getAll();
        setRewards(fetchedRewards);
      } catch (err: unknown) {
        const errorMessage = getErrorMessage(err, 'Failed to load rewards. Please try again.');
        setError(errorMessage);
        logger.apiError('/rewards', err);
      } finally {
        setLoading(false);
      }
    };

    fetchRewards();
  }, []);

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
      await redemptionsApi.create(user.id, selectedReward.id);
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
      setRewards(updatedRewards);

      // Clear success message after 5 seconds
      setTimeout(() => setSuccessMessage(null), 5000);
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
