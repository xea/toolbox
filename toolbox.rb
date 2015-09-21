require_relative 'lib/core'
require_relative "lib/service/console"
require_relative 'lib/service/logger'

core = Core.new :toolbox
core.register_service :console, ConsoleService.new
core.commit_stage

core.register_service :heartbeat, HeartBeatService.new
core.register_service :listener, HeartBeatListener.new

core.bootstrap
puts 'Main thread finished. Exiting...'
