require_relative "core/service"

# Enables user-interaction with the framework via keyboard inputs
class Console < Service

    required_features :logger

    def start
        @logger.info "Starting console"
    end

    def stop
        @logger.info "Stopping console"
    end

end
