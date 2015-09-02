p Thread.current

require_relative "lib/core"
require_relative "lib/console"
require_relative "lib/logger"
require "logger"

core = Core.new :toolbox
#core.register_service :console, ConsoleService.new, [ :console ]
#core.register_service :logger, LoggerService.new, [ :logger ]

core.framework.register_service :heartbeat, HeartBeatService.new
core.framework.register_service :listener, HeartBeatListener.new

core.bootstrap
puts "Program finished"
