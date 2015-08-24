require_relative "service_registration"

# A Service Registry is a collection of registered objects that are framework services themselves. Each service
# may have a list of features it supports.
module ServiceRegistry

    SERVICE_FEATURE = :service

    # Register a new service object along with it's feature set
    def register_service(id, service, features = [], options = { autostart: true })
        unless service_registry.has_key? id
            service.service_id = id
            features << SERVICE_FEATURE unless features.member? SERVICE_FEATURE
            service_registry[id] = ServiceRegistration.new(id, service, features, options)

            # Optional callback method notifying the listener that the registration has completed
            service_registered service_registry[id] if respond_to? :service_registered, true
        else
            raise "Service with id #{id} has been registered"
        end
    end

    # Unregister a previously registered service by it's id
    def unregister_service(id)
        service_registry.delete id
    end

    # Retrieve a service registration based on service id
    def service(id)
        service_registry[id].service if service_registry.has_key? id
    end

    # Find a service that has the capabilities specified by spec additionally narrowed by blk
    def find(spec = SERVICE_FEATURE, &blk)
        find_all(spec, &blk)[0]
    end

    # Find all the services that have the specified capabilities or an empty array if none was found
    def find_all(spec = SERVICE_FEATURE, &blk)
        base = service_registry.values.find_all { |service| service[:features].member? spec }

        unless blk.nil?
            base = base.find_all { |service| blk.call(service.service) }
        end

        base
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
