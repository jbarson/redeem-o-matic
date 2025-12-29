class CreateRewards < ActiveRecord::Migration[8.0]
  def change
    create_table :rewards do |t|
      t.string :name, null: false
      t.text :description
      t.integer :cost, null: false
      t.string :image_url
      t.string :category
      t.integer :stock_quantity
      t.boolean :active, default: true, null: false

      t.timestamps
    end
  end
end
