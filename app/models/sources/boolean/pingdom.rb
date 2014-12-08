module Sources
  module Boolean

    class Pingdom < Sources::Boolean::Base

      def available?
      	pingdom = BackendSettings.secrets.pingdom or return false
        %w[user password api_key].all? do |key|
          pingdom.send(:[], key).present?
        end
      end

      def custom_fields
        [
          { :name => "check", :title => "Check Name", :mandatory => true}
        ]
      end

      def get(options = {})
        widget = Widget.find(options.fetch(:widget_id))
        settings = widget.settings
        connection = SimplePingdomInterface.new.make_request
        { :value => connection.status_ok?(settings.fetch(:check)) }
      end

    end

  end
end
