class Withdrawal < Transfer

  def transfer_amount
    - read_attribute(:amount)
  end
end