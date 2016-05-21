class CoreTransaction

    def initialize(core = nil)
        @core = core
        @tx_requests = []
        @committed = false

        restricted_methods = []
        local_methods = @core.methods - (Object.methods - restricted_methods)

        local_methods.each do |method|
            define_singleton_method(method) do |*args, &blk|
                @tx_requests << { method: method, args: args, block: blk }
            end
        end
    end

    def commit
        @core.commit_tx(@tx_requests) unless committed?
        @committed = true
    end

    def rollback
        @tx_requests = [] unless committed?
    end

    def dirty?
        !@tx_requests.empty?
    end

    def committed?
        @committed
    end
end
