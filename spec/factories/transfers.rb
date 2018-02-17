FactoryBot.define do
  factory :deposit do
    amount 10
    balance_before 10
    balance_after 20
    items { { amount: 10, count: 1 } }
  end

  factory :withdrawal do
    amount 10
    balance_before 10
    balance_after 20
    items { { amount: 10, count: 1 } }
  end
end