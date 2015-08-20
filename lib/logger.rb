require_relative "core/service"

class LoggerService < Service

    def raw(level, message)
        puts message
    end
end
