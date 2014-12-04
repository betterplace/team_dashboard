module Sources
  module StatusTable
    class Pingdom < Sources::StatusTable::Base

      def available?
        %i(pingdom_user, pingdom_password pingdom_api_key).all? do |key|
          BackendSettings.secrets.send(key).present?
        end
      end

      def get(options = {})
        connection = SimplePingdomInterface.new.make_request
        build_json_response(connection.status_table)
      end

    end
  end
end
