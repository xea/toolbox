require 'pg'
require_relative 'postgres_mode'

class PSQLService < Service

    DEFAULT_CONFIG = { hostname: 'localhost', port: 5432 }

    optional_features :console, :logger

    def feature_console_up(console)
        @console = console
        @console.register_helper :pg, self
        @console.register_mode PostgresMode
    end

    def feature_console_down(console)
        @console.unregister_helper :pg
        @console = nil
    end
end

