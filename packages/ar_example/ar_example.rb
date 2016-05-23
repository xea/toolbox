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
            [
                { id: :user, class_name: User },
                { id: :preferences, class_name: Preferences }
            ]

        end

        def lookup(model_id)
            { model_id => registered_models[model_id.to_sym] }
        end
    end

    class User

        def self.attributes
            [ :uid, :name, :email, :enabled ]
        end
    end

    class Preferences

        def self.attributes
            [ :uid, :key, :value ]
        end
    end

end
