
class ActiveRecordNameSpaceProxy

    def initialize(ns)
        @ns = ns
    end

    def registered_models
        @ns.registered_models
    end

    def lookup(model_id)
        @ns.lookup(model_id)
    end
end

module ActiveRecordNameSpace

    def registered_models
        # Example: [ { class_name: ExampleModel } ]
        []
    end

    def lookup(model_id)
        nil
    end
end
