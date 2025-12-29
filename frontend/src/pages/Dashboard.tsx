import React from 'react';
import { useUser } from '../context/UserContext';

const Dashboard: React.FC = () => {
  const { user } = useUser();

  return (
    <div className="page-container">
      <h1>Dashboard</h1>
      <p>Welcome back, {user?.name}!</p>
      <p>You have {user?.points_balance} points available.</p>
    </div>
  );
};

export default Dashboard;
