class Command

    attr_reader :id, :action, :signature, :description, :options

    def initialize(id, pattern, description, options = {}, &action)
        @id = id
        @action = action
        @description = description
        @pattern = pattern
        @options = options
        if @options[:dynamic]
            @signature = nil
        else
            @signature = Signature.new pattern
        end
    end

    def method=(method)
        @method = method
    end

    def method
        if !@method.nil?
            @method
        elsif !@action.nil? and @action.respond_to? :call
            @action
        else
            lambda { }
        end
    end

end

class CommandInstance

    attr_reader :command, :args

    def initialize(command, args = nil)
        @command = command
        @args = args
    end

    def execute(args = nil)
        actual_args = args.nil? ? @args : args
        @command.action.call(*actual_args)
    end
end
