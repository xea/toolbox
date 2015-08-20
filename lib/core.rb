require_relative "core/service"
require_relative "core/service_registry"
require_relative "core/dispatcher"
require_relative "core/inject"
require_relative "core/state"
require "pry"

class Core
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
            service = service_descriptor[:service]
            service.set_state_starting
            service.start
            service.set_state_started
        end

        set_state_started
    end

    # Stop framework and every service along with it
    def stop
        set_state_stopping

        service_registry.each do |id, service_descriptor|
            service = service_descriptor[:service]
            service.set_state_stopping
            service.stop
            service.set_state_stopped
        end

        set_state_stopped
    end

protected


end

# Make procs and lambdas dependency-injectable
class Proc
    include Injectable
end

# Makes instance methods dependency-injectable
class Method
    include Injectable
end

