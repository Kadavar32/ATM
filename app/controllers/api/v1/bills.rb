module API
  module V1
    class Bills < Grape::API
      include API::V1::Defaults

      resource :bills do

        desc 'Find all bills'
        get '', root: :bills do
          Bill.all.as_json(except: [:id, :lock_version])
        end
      end
    end
  end
end
