class PostgresMode < BaseMode

    mode_id :pg
    access_from :home, "postgres", "Enter PostgreSQL mode"

    register_command(:exit_mode, 'exit', 'Exit current mode') { |intp| intp.modes.exit_mode }
    register_command(:execute_query, 'execute *query') 

    def execute_query(out, pg, query)
        result = pg.execute_query query
        p result
    end
end
