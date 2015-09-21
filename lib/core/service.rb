require_relative 'dispatcher'
require_relative 'state'
require 'celluloid/current'

# The purpose of this class is to serve as a base class for other service implementations and class tagging
class SimpleService
    attr_accessor :service_id

    include RunState

    def async
        self
    end

    def init
    end

    def start
    end

    def stop
    end

    def destroy
    end

    def feature_up(feature, service)
        instance_variable_set("@#{feature.to_s}", service)
    end

    def self.metaclass; class << self; self; end; end

    def self.traits(*arr)
        return @traits if arr.empty?

        attr_accessor(*arr)

        arr.each do |trait_id|
            metaclass.instance_eval do
                # For each trait ID we define a static method that takes some values
                define_method(trait_id) do |*trait_values|
                    @traits ||= { required_features: [], optional_features: [], provided_features: [] }
                    @traits[trait_id] = trait_values
                end

            end
        end

        class_eval do
            define_method(:initialize) do |*args|
                # Reset traits is a hack to allow classes to omit feature declaration. 
                self.class.reset_traits nil
                self.class.traits.each do |k, v|
                    instance_variable_set("@#{k}", v)
                end
            end
        end
    end

    traits :required_features, :optional_features, :provided_features, :reset_traits

end

class Service < SimpleService
    include Celluloid
end

# A placeholder proxy for a service object that intercepts method invocations on the service object and
# translates method calls with call requests enabling call auditing, authenticating and authorization.
class ServiceProxy

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
            proxy = ServiceProxy.new

            # for each service method we define a singleton method that generates ServiceRequest objects instead
            # of actual method calls
            local_methods.each do |method|
                proxy.define_singleton_method(method) { |*args, &block|
                    request = ServiceRequest.new dispatcher, service, method, args, block
                    dispatcher.dispatch request
                }
            end

            proxy
        end
    end
end

