# The purpose of this class is to serve as a base class for other service implementations and class tagging
class Service
    attr_accessor :service_id
end

# A placeholder proxy for a service object that intercepts method invocations on the service object and
# translates method calls with call requests enabling call auditing, authenticating and authorization.
class ServiceRegistration

    # Accepts an object of a subclass of Service and replaces all of the service methods with request
    # translator methods.
    def self.consume(service, dispatcher)
        if service.nil?
            raise "Registering nil service is not allowed"
        elsif dispatcher.nil?
            raise "Registering nil dispatcher is not allowed"
        elsif !service.kind_of? Service
            raise "Registering nil object is not allowed"
        elsif !dispatcher.kind_of? Dispatcher
            raise "Registering nil dispatcher is not allowed"
        else
            local_methods = service.methods - Service.instance_methods
            registration = ServiceRegistration.new

            # for each service method we define a singleton method that generates ServiceRequest objects instead
            # of actual method calls
            local_methods.each do |method|
                registration.define_singleton_method(method) { |*args, &block|
                    request = ServiceRequest.new dispatcher, service, method, args, block
                    dispatcher.dispatch request
                }
            end

            registration
        end
    end
end

# A Service Registry is a collection of registered objects that are framework services themselves. Each service
# may have a list of features it supports.
module ServiceRegistry

    # Register a new service object along with it's feature set
    def register_service(id, service, features = [])
        unless service_registry.has_key? id
            service.service_id = id
            service_registry[id] = { service: service, features: features }
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
        service_registry[id][:service] if service_registry.has_key? id
    end

protected
    
    def service_registry
        @service_registry ||= {}
    end

end
