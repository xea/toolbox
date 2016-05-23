require_relative '../core/service'
require 'logger'
require 'time'

# Very simplistic logging service. Accepts any target that has the puts and print methods.
class LoggerService < Service

    provided_features :logger

    def initialize(target = STDOUT)
        super
        # only accept the target if we can log into it
        @target = Logger.new(target)
    end

    def info(message)
        @target.info message
    end

    def method_missing(method, *args, &blk)
        @target.send method, *args, &blk
    end
end
