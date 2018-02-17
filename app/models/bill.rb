class Bill < ActiveRecord::Base
  scope :large_first, -> { order(amount: :desc) }

  def total_amount
    amount * count
  end
end