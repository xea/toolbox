class PostgresMode < BaseMode

    mode_id :postgres
    access_from :home, "postgres", "Enter PostgreSQL mode"

    register_command(:exit_mode, 'exit', 'Exit current mode') { |intp| intp.modes.exit_mode }
    register_command(:connect_to, 'connect :server :db :username? :password?')
    register_command(:execute_query, 'execute *query')

    def execute_query(out, pg, query)
        result = pg.execute_query query
        p result
    end

    def connect_to(out, server, db, username, password)
        out.puts "Connecting to server at #{server} to #{db}"
    end
end
