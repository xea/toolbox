require_relative "command"
require_relative "context"
require_relative "mode"
require_relative "mode_registry"
require_relative "mode_global"
require_relative "mode_home"
require_relative "mode_debug"
require_relative "mode_core"
require 'pry'

class Interpreter

    attr_reader :modes

    def initialize(pure = false)
        @modes = ModeRegistry.new
        @tables = {}
        @state = InterpreterState.new(@modes, @tables)
        @helpers = { intp: @state, out: STDOUT }

        unless pure
            register_mode ModeGlobal, :global
            register_mode ModeHome, :local
            register_mode ModeDebug, :local
            register_mode ModeCore, :local
            @modes.enter_mode :global
            @modes.enter_mode :home
        end

        MethodSource::MethodExtensions.set_interpreter_instance self
    end
    
    # Removes unnecessary white spaces (and possibly other unwanted characters)
    # from the given input string.
    #
    # Note: this method doesn't touch quoted parts, ie. that are surrounded by (") characters
    def sanitize_input(input)
		input.to_s.scan(/("[^"]+?"|\S+)/).flatten.join " "
    end

    # Takes a line of user input from the standard input, attempts to look up the appropriate reponse to
    # the request and execute it.
    def process(raw_input)
        clean_input = sanitize_input raw_input

        if clean_input.length > 0
            command = find_command(clean_input) || @modes.global_mode.command_not_found

            user_args = extract_user_args command, clean_input
            command_ctx = build_context(command, user_args)
            args = resolve_args(command, command_ctx)

            command.method.call(*args)
        end
    end

    def register_helper(id, helper)
        @helpers[id] = helper
    end
    
    def register_mode(mode, type)
        if !mode.nil? and mode.ancestors.member? BaseMode
            mode_instance = mode.new
            mode_instance.tables.each { |id, table| @tables[id] = table }

            if type == :global
                @modes.register_global_mode mode
            else
                @modes.register_mode mode
            end
        end
    end

    # Attempts to find an request handler for the current input. It might return nil when there's no 
    # corresponding handler to the input or it might return a command object containing the vital 
    # information to react
    def find_command(input)
        @modes.active_modes.map { |mode| mode.find_command(input) }.find { |command| !command.nil? }
    end

    def extract_user_args(command, input)
        unless command.signature.nil?
            command.signature.extract input
        else
            {}
        end
    end

    def build_context(command = nil, user_args = {})
        ctx = CommandContext.new
        ctx.user_args = lookup_args(user_args)
        ctx.helpers = @helpers.clone
        ctx.tables = @tables.clone
        ctx.helpers[:current_mode] = @modes.current_mode
        ctx
    end

    def lookup_args(user_args)
        Hash[*(user_args.map { |k, v| [ k.gsub(/^[:$#](.*)[+!]?/, "\\1").to_sym, lookup_arg(k, v) ] }.flatten)]
    end

    def lookup_arg(key, arg)
        case key[0]
        when "$"
            table_lookup(key, arg)
        when "#"
            attribute_lookup(key, arg)
        else
            placeholder_lookup(key, arg)
        end
    end

    # Perform a key lookup in the registered data tables
    def table_lookup(key, arg)
        table = @tables.find { |id, current_table| current_table.has_key? arg.to_sym }
        table[1][arg.to_sym] unless table.nil?
    end

    def attribute_lookup(key, arg)
        arg
    end

    def placeholder_lookup(key, arg)
        arg
    end

    # Selects arguments from the current context that the given command requires.
    def resolve_args(command, ctx)
        resolvers = ctx.preferred

        if command.kind_of? Method or command.kind_of? Proc
            method = command
        elsif command.kind_of? Command
            method = command.method
        end

        method.parameters.map do |param|
            param_name = param[1]

            preferred_resolver = resolvers.find { |resolver| resolver.has_key? param_name unless resolver.nil? }

            if !preferred_resolver.nil?
                preferred_resolver[param_name]
            elsif param[0] == :req
                raise "Couldn't find value for required parameter #{param_name}"
            else
                nil
            end
        end unless method.nil?
    end
end

class InterpreterState

    attr_reader :modes, :tables

    def initialize(modes = {}, tables = {})
        @modes = modes
        @tables = tables
    end

    def quit
        exit 0 
    end
end

module MethodSource::MethodExtensions
    def self.set_interpreter_instance(interpreter)
        @@interpreter = interpreter
    end

    def call_resolved
        unless @@interpreter.nil?
            command_ctx = @@interpreter.build_context
            args = @@interpreter.resolve_args(self, command_ctx)
            call(*args)
        else
            call
        end
    end
end
