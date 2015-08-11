module Resolver
end

# Dummy resolver that doesn't do actual resolving
class NilResolver
    include Resolver
end

# Injectable modules are subject to dependency injection
module Injectable
    # Attemts to call the current code block (lambda/proc) 
    def inject(resolver = NilResolver.new)
    end
end
