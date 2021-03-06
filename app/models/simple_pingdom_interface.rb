class SimplePingdomInterface

  class UnknownLabelError < StandardError ; end

  attr_reader :response
  attr_accessor :user, :pass, :app_key

  def initialize
    @user = BackendSettings.secrets.pingdom['user']
    @pass = BackendSettings.secrets.pingdom['password']
    @app_key = BackendSettings.secrets.pingdom['api_key']
  end

  def pingdom_url
    @pingdom_url ||= "https://#{CGI.escape(user)}:#{pass}@api.pingdom.com/api/2.0/checks"
  end

  def make_request
    @response = ::HttpService.request(pingdom_url, :headers => { 'App-Key' => app_key } )
    self
  end

  def find_by_label(label)
    status_table.find { |entry| entry['label'] == label } || raise(UnknownLabelError, label)
  end

  def value(label)
    find_by_label(label)['value']
  end

  def status_ok?(label)
    find_by_label(label)['status'] == 0
  end

  def status_table
    response['checks'].map do |check|
      {
        'label' => check['name'],
        'value' => check['lastresponsetime'],
        'status' => (check['status'] == 'up') ? 0 : 2
      }
    end
  end

end
