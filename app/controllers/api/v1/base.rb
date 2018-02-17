module API
  module V1
    class Base < Grape::API
      mount API::V1::Bills
      mount API::V1::Withdrawals
      mount API::V1::Deposits
    end
  end
end
