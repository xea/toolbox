require 'active_record'
require 'activerecord-jdbc-adapter' if defined? JRUBY_VERSION
require 'activerecord-jdbcpostgresql-adapter' if defined? JRUBY_VERSION
require 'safe_attributes/base'
require 'core/service'

class ActiveRecordService < Service

    required_features :config
    provided_features :ar

    def start
        @namespaces = {}
    end

    def stop
        @namespaces = {}
    end

    def register_namespace(namespace_id, namespace)
        @namespaces[namespace_id] = namespace
    end

    def unregister_namespace(namespace_id)
        ns = @namespaces[namespace_id]

        unless ns.nil?
            # TODO disconnect from the DB
        end

        @namespaces[namespace_id] = nil
    end

    def namespace(namespace_id)
        ActiveRecordNameSpaceProxy.new
    end

end

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
