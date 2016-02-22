require_relative "service_registration"

# A Service Registry is a collection of registered objects that are framework services themselves. Each service
# may have a list of features it supports.
module ServiceRegistry

    SERVICE_FEATURE = :service

    DEFAULT_PRIORITY = 4

    # Register a new service object along with it's feature set
    def register_service(id, service, features = [], options = { autostart: true, priority: DEFAULT_PRIORITY }, &registration_callback)
        unless service_registry.has_key? id
            service.service_id = id
            features = service.provided_features if features.nil?
            features = [ features ] unless features.kind_of? Array
            features << SERVICE_FEATURE unless features.member? SERVICE_FEATURE
            options[:autostart] = true unless options.has_key? :autostart
            options[:priority] = DEFAULT_PRIORITY unless options.has_key? :priority
            service_registry[id] = ServiceRegistration.new(id, service, features, options)

            # Optional callback method notifying the listener that the registration has completed
            registration = service_registered service_registry[id] if respond_to? :service_registered, true
            registration_callback.call registration unless registration_callback.nil?

            registration
        else
            raise "Service with id #{id} has been registered"
        end
    end

    # Unregister a previously registered service by it's id
    def unregister_service(id, &unregistration_callback)
        if service_registry.has_key? id
            registration = service_unregistered service_registry[id] if respond_to? :service_unregistered, true
            unregistration_callback.call registration unless unregistration_callback.nil?

            service_registry.delete id

            registration
        else
            # TODO handle this case
        end
    end

    # Retrieve a service registration based on service id
    def service(id)
        service_registry[id].service if service_registry.has_key? id
    end

    # Find a service that has the capabilities specified by spec additionally narrowed by blk
    def find(spec = SERVICE_FEATURE, &blk)
        #active_filter = -> service { service.state? RunState::STARTED and blk.call(service) }

        find_all(spec, &blk)[0]
    end

    # Find all the services that have the specified capabilities or an empty array if none was found
    def find_all(spec = SERVICE_FEATURE, &blk)
        base = service_registry.values.find_all { |service| service[:features].member? spec }

        unless blk.nil?
            base = base.find_all { |service| blk.call(service.service) }
        end

        base = base.find_all { |service| service.service.state != RunState::UNINSTALLED }

        base.sort { |a, b| a.options[:priority] <=> b.options[:priority] }
    end

    # Find a service based on it's service id
    def find_by_id(id)
        service_registry[id]
    end

protected

    # Return the current service registry and initialise it if needed
    def service_registry
        @service_registry ||= {}
    end
end

module EmbeddedServiceRegistry

    def service_registry
        @service_registry ||= ServiceRegistry.new
    end
end

class LocalServiceRegistry
    include ServiceRegistry

    def service_registered(registration)
        registration.service.set_state_installed
        registration
    end

    def service_unregistered(registration)
        registration.service.set_state_uninstalled
        registration
    end

end
