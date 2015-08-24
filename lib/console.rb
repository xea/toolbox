require_relative "core/service"

class Console < Service

    required_features :logger

    def start
        @logger.raw "asdf", "woo hoo"
    end
end
