require_relative "core/service"

class Console < Service

    required_features :logger

    def start
        @logger.raw "woo hoo"
    end
end
