module Sources
  module StatusTable
    class Pingdom < Sources::StatusTable::Base

      def available?
      	pingdom = BackendSettings.secrets.pingdom or return false
        %w[user password api_key].all? do |key|
          pingdom.send(:[], key).present?
        end
      end

      def get(options = {})
        connection = SimplePingdomInterface.new.make_request
        build_json_response(connection.status_table)
      end
    end
  end
end
