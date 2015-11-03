class QueryRepositoryService < Service

    required_features :postgres, :config
    optional_features :console
    provided_features :query_repository

    def init
        @repository = {}
    end

    def destroy
        @repository = {}
    end

    def execute(query_id)
    end
end
