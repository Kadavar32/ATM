module API
  module V1
    class Withdrawals < Grape::API
      include API::V1::Defaults

      resource :withdrawals do
        before do
          @service = WithdrawalsService.new
        end

        desc 'Get Cash from ATM'
        params do
          requires :amount, type: Integer, desc: 'Amount of money'
        end

        post '', root: :withdrawals do
          withdrawal = @service.create(params[:amount])
          withdrawal.as_json(except: [:balance_before, :balance_after])
        end

        desc 'find all Withdrawals'

        get '', root: :withdrawals do
          @service.find_all
        end
      end
    end
  end
end
