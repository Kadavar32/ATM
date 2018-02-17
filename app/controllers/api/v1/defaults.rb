module API
  module V1
    module Defaults
      extend ActiveSupport::Concern

      included do
        prefix 'api'
        version 'v1', using: :header, vendor: 'kadavarATM'
        default_format :json
        format :json

        helpers do
          def logger
            Rails.logger
          end
        end

        rescue_from ServiceError do |e|
          logger.error("Error: #{e.class}: #{e.message}")
          error_response(message: e.message, status: 422)
        end
      end
    end
  end
end
