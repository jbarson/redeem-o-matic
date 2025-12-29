import { render, screen } from '@testing-library/react';
import PointsBalance from '../user/PointsBalance';
import { UserProvider } from '../../context/UserContext';

// Mock UserContext
jest.mock('../../context/UserContext', () => ({
  ...jest.requireActual('../../context/UserContext'),
  useUser: jest.fn(),
}));

const { useUser } = require('../../context/UserContext');

describe('PointsBalance', () => {
  it('displays points balance with formatted number', () => {
    useUser.mockReturnValue({
      user: { id: 1, name: 'John Doe', email: 'john@example.com', points_balance: 1500 },
    });

    render(<PointsBalance />);

    expect(screen.getByText('1,500')).toBeInTheDocument();
    expect(screen.getByText('Your Balance')).toBeInTheDocument();
    expect(screen.getByText('points')).toBeInTheDocument();
  });

  it('formats large numbers with commas', () => {
    useUser.mockReturnValue({
      user: { id: 1, name: 'Jane Smith', email: 'jane@example.com', points_balance: 1234567 },
    });

    render(<PointsBalance />);

    expect(screen.getByText('1,234,567')).toBeInTheDocument();
  });

  it('displays zero balance correctly', () => {
    useUser.mockReturnValue({
      user: { id: 1, name: 'Zero User', email: 'zero@example.com', points_balance: 0 },
    });

    render(<PointsBalance />);

    expect(screen.getByText('0')).toBeInTheDocument();
  });

  it('displays small balance without commas', () => {
    useUser.mockReturnValue({
      user: { id: 1, name: 'Small User', email: 'small@example.com', points_balance: 100 },
    });

    render(<PointsBalance />);

    expect(screen.getByText('100')).toBeInTheDocument();
  });

  it('returns null when no user is logged in', () => {
    useUser.mockReturnValue({ user: null });

    const { container } = render(<PointsBalance />);

    expect(container.firstChild).toBeNull();
  });
});
