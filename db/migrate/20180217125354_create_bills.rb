class CreateBills < ActiveRecord::Migration[5.1]
  def change
    create_table :bills do |t|
      t.integer :amount, null: false
      t.integer :count, default: 0
    end

    add_index :bills, :amount, unique: true
  end
end
