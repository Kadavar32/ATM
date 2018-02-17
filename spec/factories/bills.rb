FactoryBot.define do
  factory :bill do
    amount [1, 2, 5, 10, 25, 50].sample
    # count rand(1..100)
  end
end