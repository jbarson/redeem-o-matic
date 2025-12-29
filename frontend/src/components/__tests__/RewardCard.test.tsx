import { render, screen, fireEvent } from '@testing-library/react';
import RewardCard from '../rewards/RewardCard';
import { Reward } from '../../types';

describe('RewardCard', () => {
  const mockReward: Reward = {
    id: 1,
    name: 'Test Reward',
    description: 'Test Description',
    cost: 500,
    category: 'Gift Card',
    active: true,
  };

  const mockOnRedeem = jest.fn();

  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('renders reward information', () => {
    render(<RewardCard reward={mockReward} userBalance={1000} onRedeem={mockOnRedeem} />);

    expect(screen.getByText('Test Reward')).toBeInTheDocument();
    expect(screen.getByText('Test Description')).toBeInTheDocument();
    expect(screen.getByText('500')).toBeInTheDocument();
    expect(screen.getAllByText('Gift Card').length).toBeGreaterThan(0);
  });

  it('calls onRedeem when button clicked with sufficient balance', () => {
    render(<RewardCard reward={mockReward} userBalance={1000} onRedeem={mockOnRedeem} />);

    const button = screen.getByRole('button', { name: /redeem/i });
    fireEvent.click(button);

    expect(mockOnRedeem).toHaveBeenCalledWith(mockReward);
  });

  it('disables button when insufficient points', () => {
    render(<RewardCard reward={mockReward} userBalance={100} onRedeem={mockOnRedeem} />);

    const button = screen.getByRole('button');
    expect(button).toBeDisabled();
    expect(button).toHaveTextContent('Insufficient Points');
  });

  it('disables button when out of stock', () => {
    const outOfStockReward = { ...mockReward, stock_quantity: 0 };
    render(<RewardCard reward={outOfStockReward} userBalance={1000} onRedeem={mockOnRedeem} />);

    const button = screen.getByRole('button');
    expect(button).toBeDisabled();
    expect(button).toHaveTextContent('Out of Stock');
  });

  it('does not call onRedeem when button is disabled', () => {
    render(<RewardCard reward={mockReward} userBalance={100} onRedeem={mockOnRedeem} />);

    const button = screen.getByRole('button');
    fireEvent.click(button);

    expect(mockOnRedeem).not.toHaveBeenCalled();
  });

  it('displays category placeholder when no image URL', () => {
    render(<RewardCard reward={mockReward} userBalance={1000} onRedeem={mockOnRedeem} />);

    // The category should be displayed
    expect(screen.getByText('Gift Card')).toBeInTheDocument();
    
    // The placeholder image should be used (contains category in URL)
    const image = screen.getByAltText('Test Reward');
    expect(image).toBeInTheDocument();
    expect(image).toHaveAttribute('src', expect.stringContaining('Gift%20Card'));
  });

  it('displays image when image URL provided', () => {
    const rewardWithImage = { ...mockReward, image_url: 'https://example.com/image.jpg' };
    render(<RewardCard reward={rewardWithImage} userBalance={1000} onRedeem={mockOnRedeem} />);

    const image = screen.getByAltText('Test Reward');
    expect(image).toBeInTheDocument();
    expect(image).toHaveAttribute('src', 'https://example.com/image.jpg');
  });

  it('shows available stock when stock_quantity is present', () => {
    const rewardWithStock = { ...mockReward, stock_quantity: 5 };
    render(<RewardCard reward={rewardWithStock} userBalance={1000} onRedeem={mockOnRedeem} />);

    expect(screen.getByText(/5 available/i)).toBeInTheDocument();
  });

  it('does not show stock when stock_quantity is null', () => {
    const rewardWithUnlimitedStock = { ...mockReward, stock_quantity: null };
    render(<RewardCard reward={rewardWithUnlimitedStock} userBalance={1000} onRedeem={mockOnRedeem} />);

    expect(screen.queryByText(/available/i)).not.toBeInTheDocument();
  });
});
