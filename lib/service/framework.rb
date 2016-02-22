require_relative '../core/service'

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

    def service(spec = ServiceRegistry::SERVICE_FEATURE, &blk)
        service_candidate = @core.service_registry.find(spec, &blk)
        service_candidate.service unless service_candidate.nil?
    end

    def register_service(id, service, features = nil)
        @core.register_service id.to_sym, service, features
    end

    def unregister_service(id)
        @core.unregister_service id.to_sym
    end

    def stage(reuse_last = false)

    end

    def find_services(spec = ServiceRegistry::SERVICE_FEATURE, &blk)
        @core.service_registry.find_all spec, &blk
    end

    def begin_tx(&blk)
        @core.begin_tx(&blk)
    end

    def start_service(service_id)
        service_registration = @core.service_registry.find { |service| service.service_id == service_id.to_sym }
        @core.start_service service_registration unless service_registration.nil?
    end

    def stop_service(service_id)
        service_registration = @core.service_registry.find { |service| service.service_id == service_id.to_sym }
        @core.stop_service service_registration unless service_registration.nil?
    end
end
