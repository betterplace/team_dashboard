# Nodejs Uptime Datasource Plug-in
# https://github.com/fzaninotto/uptime
# Version: 0.1.0
# Date: 22.6.2013
# Implemented by Shuky Dvir
# e-mail: shuky.dvir@gmail.com

# Find the configuration variables in your plugins.yml:
#
#   uptime:
#     url: <%= ENV['UPTIME_URL'] %>
#
module Sources
  module Boolean
    class NodejsUptime < Sources::Boolean::Base
      class NotFoundError < StandardError; end

      def available?
        cc(:plugins).uptime?
      end

      def custom_fields
        [
          { :name => "check_name", :title => "Check name", :mandatory => true }
        ]
      end

      def get(options = {})
        widget           = Widget.find(options.fetch(:widget_id))
        check_name       = widget.settings.fetch(:check_name)

        response = ::HttpService.request(cc(:plugins).uptime.url)
        Rails.logger.info response
        response.each do |item|
          if item["name"] == check_name
            if item["isUp"] == true
              return { :value => true }
            else
              Rails.logger.warn("Uptime: '#{check_name}' check is down!")
              return { :value => false }
            end
          end
        end

        Rails.logger.fatal("Could not find a Uptime check with the name '#{check_name}'!")
        raise NotFoundError
      end
    end
  end
end
