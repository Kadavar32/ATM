class AddVersionLockToBills < ActiveRecord::Migration[5.1]
  def change
    add_column :bills, :lock_version, :integer
  end
end
