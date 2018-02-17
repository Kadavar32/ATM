class CreateTransfers < ActiveRecord::Migration[5.1]
  def change
    create_table :transfers do |t|
      t.integer :amount, default: 0
      t.integer :balance_before, default: 0
      t.integer :balance_after, default: 0
      t.string  :type
      t.json :items

      t.timestamps
    end
  end
end
