require 'active_record'
require 'activerecord-jdbc-adapter' if defined? JRUBY_VERSION
require 'activerecord-jdbcpostgresql-adapter' if defined? JRUBY_VERSION
require 'safe_attributes/base'

class ActiveRecordService < Service

    required_features :config
    provided_features :activerecord

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
        @namespaces[namespace_id] = nil
    end
end

=begin
class SandboxDB < ActiveRecord::Base

    self.abstract_class = true
    establish_connection "sandbox"
end
=end
