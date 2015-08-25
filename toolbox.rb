require_relative "lib/core"
require_relative "lib/console"
require_relative "lib/logger"
require "logger"

core = Core.new :toolbox
core.register_service :console, ConsoleService.new, [ :console ]
core.register_service :logger, LoggerService.new, [ :logger ]

core.start
