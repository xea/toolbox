class ActiveRecordExampleService < Service

    required_features :ar

    def start
        @ar.register_namespace :example, ExampleNamespace.new
    end

    def stop
        @ar.unregister_namespace :example
    end

    class ExampleNamespace

        def registered_models
            {
                user: User,
                preferences: Preferences
            }
        end

        def lookup(model_id)
            { model_id => registered_models[model_id.to_sym] }
        end
    end

    class User
    end

    class Preferences
    end
end
