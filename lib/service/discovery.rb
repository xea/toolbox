require_relative '../core/service'

class DiscoveryService < Service

    required_features :framework, :config
    optional_features :logger
    provided_features :discovery

    def start
    end

    def stop
    end
end
