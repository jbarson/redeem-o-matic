class CreateRedemptions < ActiveRecord::Migration[8.0]
  def change
    create_table :redemptions do |t|
      t.references :user, null: false, foreign_key: true, index: true
      t.references :reward, null: false, foreign_key: true, index: true
      t.integer :points_spent, null: false
      t.string :status, default: "completed", null: false

      t.timestamps
    end

    add_index :redemptions, :created_at
  end
end
