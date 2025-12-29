import React from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useUser } from '../../context/UserContext';
import '../../styles/Header.css';

const Header: React.FC = () => {
  const { user, logout } = useUser();
  const navigate = useNavigate();

  const handleLogout = () => {
    logout();
    navigate('/login');
  };

  if (!user) {
    return null;
  }

  return (
    <header className="app-header">
      <div className="header-content">
        <div className="logo">
          <Link to="/">Redeem-O-Matic</Link>
        </div>

        <nav className="main-nav">
          <Link to="/" className="nav-link">Dashboard</Link>
          <Link to="/rewards" className="nav-link">Rewards</Link>
          <Link to="/history" className="nav-link">History</Link>
        </nav>

        <div className="user-section">
          <div className="user-info">
            <span className="user-name">{user.name}</span>
            <span className="user-points">{user.points_balance} pts</span>
          </div>
          <button onClick={handleLogout} className="logout-button">
            Logout
          </button>
        </div>
      </div>
    </header>
  );
};

export default Header;
