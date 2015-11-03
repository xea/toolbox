require 'pg'
require_relative 'postgres_mode'

# Offers low-level PostgreSQL access
class PSQLService < Service

    DEFAULT_CONFIG = { hostname: 'localhost', port: 5432 }

    optional_features :console, :logger
    provided_features :postgres

    def feature_console_up(console)
        @console = console
        @console.register_helper :pg, Actor.current
        @console.register_mode PostgresMode
    end

    def feature_console_down(console)
        @console.unregister_helper :pg
        @console = nil
    end

    def connect_to(conninfo)
        begin
            connection = PG.connect(conninfo)
            PGConnection.new connection
        rescue PG::Error => error
            # TODO error handling
        end
    end
end

class PGConnection

    def initialize(connection)
        @connection = connection
    end
end
