import React from 'react';
import { Redemption } from '../../types';
import '../../styles/RedemptionHistory.css';

interface RedemptionHistoryProps {
  redemptions: Redemption[];
}

const RedemptionHistory: React.FC<RedemptionHistoryProps> = ({ redemptions }) => {
  if (redemptions.length === 0) {
    return (
      <div className="empty-state">
        <p>No redemptions yet. Start redeeming rewards to see your history here!</p>
      </div>
    );
  }

  const formatDate = (dateString: string) => {
    const date = new Date(dateString);
    return date.toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'long',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
    });
  };

  return (
    <div className="redemption-history">
      {redemptions.map((redemption) => (
        <div key={redemption.id} className="redemption-item">
          <div className="redemption-image">
            {redemption.reward.image_url ? (
              <img src={redemption.reward.image_url} alt={redemption.reward.name} />
            ) : (
              <div className="image-placeholder">Reward</div>
            )}
          </div>

          <div className="redemption-details">
            <h3 className="redemption-name">{redemption.reward.name}</h3>
            <p className="redemption-date">{formatDate(redemption.created_at)}</p>
          </div>

          <div className="redemption-cost">
            <span className="cost-amount">-{redemption.points_spent}</span>
            <span className="cost-label">points</span>
          </div>

          <div className={`redemption-status status-${redemption.status}`}>
            {redemption.status}
          </div>
        </div>
      ))}
    </div>
  );
};

export default RedemptionHistory;
