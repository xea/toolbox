# Selects an appropriate handler for service requests
module Dispatcher

    def dispatch(request)
        service = request.service
        method = service.method(request.method)
        method.call(*request.args)
    end
end

# Encapsulates a command execution performed on a service object
class ServiceRequest

    attr_reader :dispatcher, :service, :method, :args, :block

    def initialize(dispatcher, service, method, args, block)
        @service = service
        @method = method
        @args = args
        @block = block
        @dispatcher = dispatcher
    end
end
