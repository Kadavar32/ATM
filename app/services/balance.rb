module Balance
  def build_transfer(transfer_type, items, amount: nil, balance_before: 0)
    amount ||= process_items_amount(items)
    transfer = transfer_type.new(amount: amount, items: items)
    transfer.balance_before = balance_before
    transfer.balance_after = transfer.balance_before + transfer.transfer_amount
    transfer
    Rails.logger.info "Transfer: #{transfer.inspect}"

    transfer
  end

  def process_items_amount(items)
    items.inject(0) { |amount, bill| amount + bill_total_amount(bill) }
  end

  def total_balance(bills: nil)
    bills ||= Bill.all
    bills.inject(0) { |amount, bill| amount + bill.total_amount }
  end

  def load_bills
    Bill.large_first
  end

  def bill_total_amount(bill)
    bill[:amount].to_i * bill[:count].to_i
  end

  def with_optimistic_lock(max_retry_attempts: 5)
    attempts ||= 0
    yield
  rescue ActiveRecord::StaleObjectError => e
    Rails.logger.info "#{e.class}, #{e.message}"
    raise ServiceError, MAX_ATTEMPTS_ERROR if attempts >= max_retry_attempts
    attempts += 1
    retry
  end
end