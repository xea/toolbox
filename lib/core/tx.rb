class CoreTransaction

    def initialize(core = nil)
        @core = core
        @tx_requests = []

        restricted_methods = []
        local_methods = @core.methods - (Object.methods - restricted_methods)

        local_methods.each do |method|
            define_singleton_method(method) do |*args, &blk|
                @tx_requests << { method: method, args: args, block: blk }
            end
        end
    end

    def commit
        @core.commit_tx(@tx_requests)
    end

    def rollback
        @tx_requests = []
    end

    def dirty?
        !@tx_requests.empty?
    end
end
