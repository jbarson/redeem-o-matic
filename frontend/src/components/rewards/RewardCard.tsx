import React from 'react';
import { Reward } from '../../types';
import '../../styles/RewardCard.css';

interface RewardCardProps {
  reward: Reward;
  userBalance: number;
  onRedeem: (reward: Reward) => void;
}

const RewardCard: React.FC<RewardCardProps> = ({ reward, userBalance, onRedeem }) => {
  const canAfford = userBalance >= reward.cost;
  const isOutOfStock = reward.stock_quantity !== null && reward.stock_quantity !== undefined && reward.stock_quantity <= 0;
  const isDisabled = !canAfford || isOutOfStock;

  return (
    <div className="reward-card">
      <div className="reward-image">
        {reward.image_url ? (
          <img src={reward.image_url} alt={reward.name} />
        ) : (
          <div className="reward-placeholder">{reward.category}</div>
        )}
      </div>

      <div className="reward-content">
        <div className="reward-category">{reward.category}</div>
        <h3 className="reward-name">{reward.name}</h3>
        <p className="reward-description">{reward.description}</p>

        <div className="reward-footer">
          <div className="reward-cost">
            <span className="cost-amount">{reward.cost}</span>
            <span className="cost-label">points</span>
          </div>

          {reward.stock_quantity !== null && reward.stock_quantity !== undefined && (
            <div className="reward-stock">
              {reward.stock_quantity > 0 ? (
                <span className="stock-available">{reward.stock_quantity} available</span>
              ) : (
                <span className="stock-out">Out of stock</span>
              )}
            </div>
          )}
        </div>

        <button
          className={`redeem-button ${isDisabled ? 'disabled' : ''}`}
          onClick={() => onRedeem(reward)}
          disabled={isDisabled}
        >
          {isOutOfStock ? 'Out of Stock' : !canAfford ? 'Insufficient Points' : 'Redeem'}
        </button>
      </div>
    </div>
  );
};

export default RewardCard;
