import React from 'react';
import { Reward } from '../../types';
import '../../styles/ConfirmModal.css';

interface ConfirmModalProps {
  reward: Reward;
  userBalance: number;
  onConfirm: () => void;
  onCancel: () => void;
}

const ConfirmModal: React.FC<ConfirmModalProps> = ({
  reward,
  userBalance,
  onConfirm,
  onCancel,
}) => {
  const newBalance = userBalance - reward.cost;

  return (
    <div className="modal-overlay" onClick={onCancel}>
      <div className="modal-content" onClick={(e) => e.stopPropagation()}>
        <h2>Confirm Redemption</h2>

        <div className="modal-body">
          <div className="reward-summary">
            <h3>{reward.name}</h3>
            <p className="reward-category">{reward.category}</p>
          </div>

          <div className="balance-info">
            <div className="balance-row">
              <span>Current Balance:</span>
              <span className="balance-value">{userBalance} points</span>
            </div>
            <div className="balance-row cost">
              <span>Cost:</span>
              <span className="balance-value">-{reward.cost} points</span>
            </div>
            <div className="balance-row total">
              <span>New Balance:</span>
              <span className="balance-value">{newBalance} points</span>
            </div>
          </div>

          <p className="confirmation-text">
            Are you sure you want to redeem this reward?
          </p>
        </div>

        <div className="modal-actions">
          <button className="btn-cancel" onClick={onCancel}>
            Cancel
          </button>
          <button className="btn-confirm" onClick={onConfirm}>
            Confirm Redemption
          </button>
        </div>
      </div>
    </div>
  );
};

export default ConfirmModal;
