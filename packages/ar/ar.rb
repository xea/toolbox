require 'active_record'
require 'activerecord-jdbc-adapter' if defined? JRUBY_VERSION
require 'activerecord-jdbcpostgresql-adapter' if defined? JRUBY_VERSION
require 'safe_attributes/base'
require_relative 'ar_mode'
require_relative 'ar_ns'

class ActiveRecordService < Service

    required_features :config
    optional_features :console
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
        @namespaces.delete namespace_id
    end

    def namespace(namespace_id)
        if @namespaces.keys.member? namespace_id
            ActiveRecordNameSpaceProxy.new(namespace_id, @namespaces[namespace_id])
        else
            false
        end
    end

    def namespaces
        @namespaces.map { |id, ns| ActiveRecordNameSpaceProxy.new(id, ns) }
    end

    def feature_console_up(console)
        @console = console
        @console.register_helper :ar, Actor.current
        @console.register_mode ActiveRecordMode
    end

    def feature_console_down(console)
        @console.unregister_mode ActiveRecordMode
        @console.unregister_helper :ar
        @console = nil
    end

end
