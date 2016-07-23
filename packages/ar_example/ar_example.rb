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
                { id: :domain, class_name: Domain },
                { id: :server, class_name: Server }
            ]

        end

        def lookup(model_id)
            #{ model_id => registered_models[model_id.to_sym] }
            registered_models.find { |e| e[:id] == model_id }
        end
    end

    class ExampleBase < ActiveRecord::Base

        include ActiveRecordBaseProxy

        DEFAULT_CONNECTION = { adapter: "postgresql", hostname: "localhost", database: "ar_example", username: "postgres" }

        self.abstract_class = true
        establish_connection DEFAULT_CONNECTION

        def core_fields
            [ :rowid ]
        end
    end

    class User < ExampleBase
        has_many :domains

        def basic_fields
            [ :name ]
        end

        def verbose_fields
            [ :email ]
        end
    end

    class Domain  < ExampleBase
        belongs_to :user

        has_many :servers

        def basic_fields
            [ :domain ]
        end
    end

    class Server < ExampleBase
        belongs_to :domain

        def basic_fields
            [ :hostname, :service ]
        end

        def verbose_fields
            [ :port ]
        end
    end

end
