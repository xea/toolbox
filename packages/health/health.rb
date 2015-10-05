
class HealthChecker < Service

    required_features :logger

    def start
        @logger.info "Health check started"
    end
end
