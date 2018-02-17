module API
  module V1
    class Deposits < Grape::API
      include API::V1::Defaults

      resource :deposits do
        before do
          @service = DepositsService.new
        end

        desc 'Update Total Balance'
        params do
          group :items, type: Array, desc: 'Array of deposit items' do
            requires :amount, type: Integer
            requires :count, type: Integer
          end
        end

        post '', root: :items do
          @service.create(params[:items])
        end

        desc 'find all Deposits'

        get '', root: :deposits do
          @service.find_all
        end
      end
    end
  end
end
