import React from 'react';
import { useUser } from '../../context/UserContext';
import '../../styles/PointsBalance.css';

const PointsBalance: React.FC = () => {
  const { user } = useUser();

  if (!user) return null;

  return (
    <div className="points-balance-widget">
      <div className="balance-label">Your Balance</div>
      <div className="balance-amount">{user.points_balance.toLocaleString()}</div>
      <div className="balance-unit">points</div>
    </div>
  );
};

export default PointsBalance;
