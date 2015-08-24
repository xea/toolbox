class ServiceRegistration

    attr_reader :id, :service, :features, :options

    def initialize(id, service, features, options)
        @id = id
        @service = service
        @features = features
        @options = options
    end

    def [](key)
        case key
        when :features
            features
        when :service
            service
        when :options
            options
        when :id
            id
        end
    end
end
