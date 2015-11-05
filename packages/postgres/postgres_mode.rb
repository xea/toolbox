class PostgresMode < BaseMode

    mode_id :postgres
    access_from :home, "postgres", "Enter PostgreSQL mode"

    register_command(:exit_mode, 'exit', 'Exit current mode') { |intp| intp.modes.exit_mode }
    register_command(:connect_to, 'connect :server :db :username? :password?')
    register_command(:execute_query, 'execute *query')
    register_command(:run_query, 'run :query_id *args')

    def execute_query(out, pg, query)
        result = pg.execute_query query
        p result
    end

    def connect_to(pg, out, server, db, username = nil, password = nil)
        @conn = pg.connect_to({ host: server, dbname: db, user: username, password: password })
        out.puts "Connected to: #{@conn}"
    end

    def run_query(pg, out, query_id, args)
        query = pg.lookup query_id

        if @conn.nil?
            out.puts "You're not connected"
        else
            data = @conn.run_query(query, args)

            if data.nil?
            else
            end
        end
    end
end
