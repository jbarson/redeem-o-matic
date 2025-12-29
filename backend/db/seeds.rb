# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Clear existing data
puts "Clearing existing data..."
Redemption.destroy_all
Reward.destroy_all
User.destroy_all

# Create demo users with varying point balances
puts "Creating users..."
user1 = User.create!(
  email: 'alice@example.com',
  name: 'Alice Johnson',
  points_balance: 2500
)

user2 = User.create!(
  email: 'bob@example.com',
  name: 'Bob Smith',
  points_balance: 1500
)

user3 = User.create!(
  email: 'charlie@example.com',
  name: 'Charlie Brown',
  points_balance: 500
)

puts "Created #{User.count} users"

# Create rewards across different categories
puts "Creating rewards..."
rewards = Reward.create!([
  {
    name: '$5 Starbucks Gift Card',
    description: 'Enjoy your favorite beverage at any Starbucks location',
    cost: 500,
    category: 'Gift Card',
    image_url: 'https://via.placeholder.com/300x200/00704A/ffffff?text=Starbucks',
    active: true
  },
  {
    name: '$10 Amazon Gift Card',
    description: 'Shop millions of items on Amazon.com',
    cost: 1000,
    category: 'Gift Card',
    image_url: 'https://via.placeholder.com/300x200/FF9900/000000?text=Amazon',
    active: true
  },
  {
    name: '$25 Restaurant Voucher',
    description: 'Fine dining experience at select partner restaurants',
    cost: 2000,
    category: 'Gift Card',
    image_url: 'https://via.placeholder.com/300x200/8B4513/ffffff?text=Restaurant',
    active: true
  },
  {
    name: 'Company T-Shirt',
    description: 'Premium branded t-shirt in your choice of size',
    cost: 750,
    category: 'Merchandise',
    image_url: 'https://via.placeholder.com/300x200/4A90E2/ffffff?text=T-Shirt',
    active: true
  },
  {
    name: 'Wireless Earbuds',
    description: 'High-quality Bluetooth earbuds with charging case',
    cost: 3000,
    category: 'Merchandise',
    image_url: 'https://via.placeholder.com/300x200/000000/ffffff?text=Earbuds',
    active: true
  },
  {
    name: 'Free Coffee for a Week',
    description: 'Enjoy 7 free premium coffees at the office café',
    cost: 300,
    category: 'Perks',
    image_url: 'https://via.placeholder.com/300x200/6F4E37/ffffff?text=Coffee',
    active: true
  },
  {
    name: 'Premium Parking Spot',
    description: 'Reserved parking spot for one month in the main lot',
    cost: 1500,
    category: 'Perks',
    stock_quantity: 5,
    image_url: 'https://via.placeholder.com/300x200/2C3E50/ffffff?text=Parking',
    active: true
  },
  {
    name: 'Extra Vacation Day',
    description: 'Add an extra paid day off to your vacation balance',
    cost: 2500,
    category: 'Perks',
    stock_quantity: 10,
    image_url: 'https://via.placeholder.com/300x200/27AE60/ffffff?text=Vacation',
    active: true
  }
])

puts "Created #{Reward.count} rewards"

# Create some historical redemptions
puts "Creating historical redemptions..."
Redemption.create!([
  {
    user: user1,
    reward: rewards[0], # $5 Starbucks
    points_spent: 500,
    status: 'completed',
    created_at: 2.weeks.ago
  },
  {
    user: user1,
    reward: rewards[5], # Free Coffee
    points_spent: 300,
    status: 'completed',
    created_at: 1.week.ago
  },
  {
    user: user2,
    reward: rewards[3], # T-Shirt
    points_spent: 750,
    status: 'completed',
    created_at: 5.days.ago
  },
  {
    user: user3,
    reward: rewards[0], # $5 Starbucks
    points_spent: 500,
    status: 'completed',
    created_at: 3.days.ago
  }
])

puts "Created #{Redemption.count} redemptions"
puts "\nSeed data created successfully!"
puts "\nDemo Users:"
User.all.each do |user|
  puts "  #{user.name} (#{user.email}) - #{user.points_balance} points"
end
