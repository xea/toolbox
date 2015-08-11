require_relative "core/service"
require_relative "core/dispatcher"
require_relative "core/inject"

class Core
    include Dispatcher
    include ServiceRegistry

end

class Proc
    include Injectable
end

class Method
    include Injectable
end

c = Core.new
