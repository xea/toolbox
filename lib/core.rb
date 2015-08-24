require_relative "core/service"
require_relative "core/service_registry"
require_relative "core/dispatcher"
require_relative "core/inject"
require_relative "core/state"
require "pry"

class Core < Service
    include Dispatcher
    include ServiceRegistry
    include RunState

    attr_reader :id

    # Initialise a new framework instance identified by id
    def initialize(id)
        @id = id.to_sym
        set_state_stopped
    end

    # Start framework. It will also start every service marked to autostart as well
    def start
        set_state_starting

        service_registry.each do |id, service_descriptor|
            start_service service_descriptor
        end

        set_state_started
    end

    # Stop framework and every service along with it
    def stop
        set_state_stopping

        service_registry.each do |id, service_descriptor|
            stop_service service_descriptor
        end

        set_state_stopped
    end

protected

    def start_service(service_descriptor)
        service = service_descriptor[:service]

        if service.state? RunState::STOPPED 
            service.set_state_starting

            required_services = Hash[*(service.required_features.map do |feature|
                [ feature, find(feature) ]
            end).flatten]

            optional_services = Hash[*(service.optional_features.map do |feature|
                [ feature, find(feature) ]
            end).flatten]

            # If any of the required services is missing then we can't start the service
            unless required_services.has_value? nil
                required_services.each do |feature, req_service|
                    if req_service.service.state? RunState::STOPPED
                        start_service req_service
                    end

                    proxy = ServiceProxy.consume req_service.service, self
                    service.feature_up feature, proxy
                end

                optional_services.each do |feature, opt_service|
                    # TODO User a ServiceProxy here instead of the actual service    
                    proxy = ServiceProxy.consume opt_service.service, self
                    service.feature_up feature, proxy
                end

                service.start
                service.set_state_started
            end
        end
    end

    def service_registered(service_descriptor)
        service_descriptor[:service].set_state_stopped
        service_descriptor[:service].init
    end

    def stop_service(service_descriptor)
        service = service_descriptor[:service]
        service.set_state_stopping
        service.stop
        service.set_state_stopped
    end

private

end

# Make procs and lambdas dependency-injectable
class Proc
    include Injectable
end

# Makes instance methods dependency-injectable
class Method
    include Injectable
end

