class DepositsService
  include ErrorMessages
  include Balance

  def find_all
    Deposit.all
  end

  def create(params)
    with_optimistic_lock do
      Bill.transaction do
        balance_before = total_balance
        Rails.logger.info "Total Balance before #{balance_before}"
        items_data = process_items(params)
        deposit = build_transfer(Deposit, items_data, balance_before: balance_before)
        deposit.save!

        deposit
      end
    end
  end

  private

  def process_items(params)
    params.map do |e|
      unless (bill = Bill.find_by(amount: e[:amount])).present?
        Rails.logger.info "Bill not found, params: #{e}"
        next
      end
      bill.count += e[:count]
      bill.save!
      Rails.logger.info "Bill #{bill.inspect} updated!"
      { amount: bill.amount, count: e[:count] }
    end.compact
  end
end
