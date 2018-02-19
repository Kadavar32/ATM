class WithdrawalsService
  include ErrorMessages
  include Balance

  def create(amount)
    with_optimistic_lock do
      Bill.transaction do
        raise ServiceError, INVALID_AMOUNT_ERROR if amount <= 0 || !is_int?(amount)
        bills = load_bills
        total_balance = total_balance(bills: bills)
        raise ServiceError, LOW_BALANCE_ERROR if amount > total_balance
        items = large_first(amount, bills)
        withdrawal = build_transfer(Withdrawal, items, balance_before: total_balance)
        withdrawal.save!

        withdrawal
      end
    end
  end

  def find_all
    Withdrawal.all
  end

  private

  def large_first(amount, bills)
    result = []
    balance = amount
    last_big_bil = 0
    bills.each do |bill|
      next if bill.count.zero?

      if balance < bill.amount
        last_big_bil = bill.amount
        next
      end

      count_of_bills = balance.to_f / bill.amount
      count_of_bills = count_of_bills > bill.count ? bill.count : count_of_bills.to_i
      balance -= (bill.amount * count_of_bills)
      bill.count -= count_of_bills
      result.push(amount: bill.amount, count: count_of_bills)
      bill.save! if bill.changed?
      break if balance == 0.0
    end

    if balance > 0
      diff = (amount - balance)
      available_amount =  diff > 0 ? diff : last_big_bil
      raise ServiceError, "#{PROCEED_ERROR} #{available_amount}"
    end

    result
  end

  def is_int?(value)
    value.to_i == value
  end
end
