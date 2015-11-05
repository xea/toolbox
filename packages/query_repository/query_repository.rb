class QueryRepositoryService < Service

    required_features :config
    optional_features :console
    provided_features :query_repository

    def init
        @repository = {
            id_select: "select 1;"
        }
    end

    def destroy
        @repository = {}
    end

    def lookup(key)
        @repository[key.to_sym]
    end
end
