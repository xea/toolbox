# Specifies a context object in which command arguments must be resolved before executing commands
class CommandContext

    attr_accessor :user_args, :tables, :helpers, :services

    def initialize
        @user_args = {}
        @tables = {}
        @helpers = {}
        @services = {}
    end

    def preferred
        [ @user_args, @tables, @services, @helpers ]
    end
end
