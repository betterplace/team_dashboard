# This unicorn configuration file is used by runit.
# For details look into betterplace/ansible-repo/roles/unicorn/main.yml

unicorn_app_folder = "."
pid_file = "#{unicorn_app_folder}/tmp/pids/unicorn.pid" # Where to drop a pidfile

pid pid_file

# What ports/sockets to listen on, and what options for them.
listen 3000, tcp_nodelay: true, backlog: 4096

working_directory unicorn_app_folder

# What the timeout for killing busy workers is, in seconds
timeout 90

# Whether the app should be pre-loaded
preload_app true

# How many worker processes
worker_processes 2

# ensure Unicorn doesn't use a stale Gemfile when restarting
# more info: https://willj.net/2011/08/02/fixing-the-gemfile-not-found-bundlergemfilenotfound-error/
before_exec do |server|
  ENV['BUNDLE_GEMFILE'] = "#{unicorn_app_folder}/Gemfile"
end

# What to do before we fork a worker
before_fork do |server, worker|
  ActiveRecord::Base.connection.disconnect!
  UnicornRelay::Teardown.new(
    pid_file: pid_file + '.oldbin',
    server:   server
  ).perform
end

# What to do after we fork a worker
after_fork do |server, worker|
  ActiveRecord::Base.establish_connection
end
