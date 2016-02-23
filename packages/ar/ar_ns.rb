
class ActiveRecordNameSpaceProxy
    def lookup(model_id)
        nil
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
