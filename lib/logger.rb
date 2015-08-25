require_relative "core/service"
require "time"

# Very simplistic logging service. Accepts any target that has the puts and print methods.
class LoggerService < Service

    def initialize(target = STDOUT)
        super
        # only accept the target if we can log into it
        unless [ :puts, :print ].map { |m| target.respond_to? m }.member? false
            @target = target
        else
            raise "Can't accept non-writeable target"
        end
    end

    def raw(level, message)
        @target.puts "#{DateTime.now.iso8601} #{level} #{message}"
    end

    def debug(message)
        raw("DEBUG", message)
    end

    def info(message)
        raw("INFO", message)
    end

    def warning(message)
        raw("WARNING", message)
    end

    def error(message)
        raw("ERROR", message)
    end
end
