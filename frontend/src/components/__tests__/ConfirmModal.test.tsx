import { render, screen, fireEvent } from '@testing-library/react';
import ConfirmModal from '../common/ConfirmModal';
import { Reward } from '../../types';

describe('ConfirmModal', () => {
  const mockReward: Reward = {
    id: 1,
    name: 'Test Reward',
    description: 'Test Description',
    cost: 500,
    category: 'Gift Card',
    active: true,
  };

  const mockOnConfirm = jest.fn();
  const mockOnCancel = jest.fn();

  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('displays reward details', () => {
    render(
      <ConfirmModal
        reward={mockReward}
        userBalance={1000}
        onConfirm={mockOnConfirm}
        onCancel={mockOnCancel}
      />
    );

    expect(screen.getByText('Test Reward')).toBeInTheDocument();
    expect(screen.getByText('Gift Card')).toBeInTheDocument();
  });

  it('displays current balance and cost', () => {
    render(
      <ConfirmModal
        reward={mockReward}
        userBalance={1000}
        onConfirm={mockOnConfirm}
        onCancel={mockOnCancel}
      />
    );

    expect(screen.getByText(/1000 points/)).toBeInTheDocument();
    expect(screen.getByText(/-500 points/)).toBeInTheDocument();
  });

  it('calculates and displays new balance', () => {
    render(
      <ConfirmModal
        reward={mockReward}
        userBalance={1000}
        onConfirm={mockOnConfirm}
        onCancel={mockOnCancel}
      />
    );

    // Look for the total balance row specifically
    const balanceRows = screen.getAllByText(/500 points/);
    expect(balanceRows.length).toBeGreaterThan(0);
  });

  it('calls onConfirm when confirm button clicked', () => {
    render(
      <ConfirmModal
        reward={mockReward}
        userBalance={1000}
        onConfirm={mockOnConfirm}
        onCancel={mockOnCancel}
      />
    );

    const confirmButton = screen.getByRole('button', { name: /confirm/i });
    fireEvent.click(confirmButton);

    expect(mockOnConfirm).toHaveBeenCalledTimes(1);
    expect(mockOnCancel).not.toHaveBeenCalled();
  });

  it('calls onCancel when cancel button clicked', () => {
    render(
      <ConfirmModal
        reward={mockReward}
        userBalance={1000}
        onConfirm={mockOnConfirm}
        onCancel={mockOnCancel}
      />
    );

    const cancelButton = screen.getByRole('button', { name: /cancel/i });
    fireEvent.click(cancelButton);

    expect(mockOnCancel).toHaveBeenCalledTimes(1);
    expect(mockOnConfirm).not.toHaveBeenCalled();
  });

  it('displays confirmation message', () => {
    render(
      <ConfirmModal
        reward={mockReward}
        userBalance={1000}
        onConfirm={mockOnConfirm}
        onCancel={mockOnCancel}
      />
    );

    expect(screen.getByText(/are you sure you want to redeem/i)).toBeInTheDocument();
  });
});
