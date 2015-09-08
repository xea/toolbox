require_relative 'service'

# Represents the micro-service framework to the framework itself.
class Framework < Service

    provided_features :framework

    def initialize(core)
        super
        @core = core
    end

    def start
        puts "Framework started"
    end

    def shutdown
        @core.shutdown
    end

    def service(feature)
        @core.service_registry.find(feature).service
    end

    def register_service(id, service, features = nil)
        @core.register_service id, service, features
    end

    def stage(reuse_last = false)

    end
end

