class PostgresMode < BaseMode

    mode_id :pg
    access_from :home, "postgres", "Enter PostgreSQL mode"

    register_command(:server_connect, "connect to :server")
    register_command(:exit_mode, 'exit', 'Exit current mode') { |intp| intp.modes.exit_mode }

    def server_connect(pg, server)
        server_parts = server.split /:/
        conn = pg.connect_to server_parts
        conn.execute "this is sparta"
    end
end
