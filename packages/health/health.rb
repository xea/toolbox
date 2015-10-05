
class HealthChecker < Service

    required_features :logger
    optional_features :console

    def start
        @logger.info "Health check started"
    end

    def feature_console_up(console)
        console.register_mode HealthCheckMode
    end

    def feature_console_down(console)
        console.unregister_mode HealthCheckMode
    end
end

class HealthCheckMode < BaseMode

    mode_id :healthcheck
    access_from :debug, "health", "Enter health check mode"

    register_command(:exit_mode, "exit", "Exit current mode") { |intp| intp.modes.exit_mode }
end
