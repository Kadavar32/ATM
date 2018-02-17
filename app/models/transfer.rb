class Transfer < ActiveRecord::Base
  def transfer_amount
    read_attribute(:amount)
  end
end