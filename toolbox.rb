require_relative 'lib/core'
#require_relative "lib/console"
require_relative 'lib/service/logger'
require 'logger'

core = Core.new :toolbox
#core.register_service :console, ConsoleService.new, [ :console ]
#core.register_service :logger, LoggerService.new, [ :logger ]
core.register_service :console, ConsoleService.new
core.commit_stage

core.register_service :heartbeat, HeartBeatService.new
core.register_service :listener, HeartBeatListener.new

core.bootstrap
puts 'Main thread finished'
