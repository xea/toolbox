require_relative "signature"
require_relative "command"

class BaseMode

    # Return metaclass for this class
    def self.metaclass; class << self; self; end; end

    # Advanced metaprogramming code for nice, clean traits
    def self.traits( *arr )
        return @traits if arr.empty?

        # 1. Set up accessors for each variable
        attr_accessor( *arr )

        # 2. Add a new class method to for each trait.
        arr.each do |a|
            metaclass.instance_eval do
                define_method( a ) do |val|
                    @traits ||= { mode_id: to_s.to_sym, commands: {}, tables: {}, filters: {}, mode_accessors: [] }
                    @traits[a] = val
                end
            end
        end

        # 3. For each monster, the `initialize' method
        #    should use the default number for each trait.
        class_eval do
            define_method( :initialize ) do |*args|
                self.class.reset_traits nil
                self.class.traits.each do |k,v|
                    instance_variable_set("@#{k}", v)
                end

                self.class.traits[:commands].each do |k, v|
                    # register possible command methods
                    unless v.action.nil?
                        define_singleton_method k, v.action
                    end

                    v.method = self.method(v.id)

                    unless v.options[:filter].nil?
                        define_singleton_method "_filter_#{k}".to_sym, v.options[:filter]
                        self.class.traits[:filters][k] = v.options[:filter]
                    end
                end

                # Calling secondary constructor to enable post-initialisation
                construct(*args)
            end
        end
    end

    # Optionally overridable secondary constructor. Allows initialisation after object construction has been completed
    # but reference hasn't been returned.
    #
    # Subclasses may override this for custom initialisation since overriding primary constructor is not advised.
    def construct(*args)
    end

    def post_enter
    end

    def pre_exit
    end

    # Mode attributes
    traits :mode_id, :commands, :tables, :filters, :reset_traits, :mode_accessors

    def self.register_command(cmd_id, cmd_pattern, cmd_desc = "<No description>", cmd_options = {}, &cmd_blk)
        @traits[:commands][cmd_id] = Command.new(cmd_id, cmd_pattern, cmd_desc, cmd_options, &cmd_blk)
    end

    def self.tables(data_tables)
        @traits[:tables] = data_tables
    end

    def self.id
        @traits[:mode_id]
    end

    def self.scope(visibility = true, &scope_filter)
        { visible: visibility, filter: scope_filter }
    end

    def self.access_from(parent_mode_id, access_command, access_command_description)
        access_command = Command.new("mode_accessor_#{parent_mode_id}_#{self.id}".to_sym, access_command, access_command_description, {}) { |intp, ctx|
            callback = intp.modes.post_enter_callback(@traits[:mode_id])
            argv = intp.resolve_args callback, ctx
            intp.modes.enter_mode self.id, *argv
        }
        @traits[:mode_accessors] << { parent: parent_mode_id, command: access_command }
    end

    # Tries to find a command where the current input matches the command pattern
    def find_command(input)
        available_commands.find { |cmd| cmd.signature.matches? input }
    end

    def visible_commands
        available_commands.find_all { |cmd| cmd.options[:visible].nil? or cmd.options[:visible] == true }
    end

    def available_commands
        commands.values.find_all do |cmd|
            if filters[cmd.id].nil?
                true
            else
                filter = method("_filter_#{cmd.id}".to_sym)
                filter.call_resolved
            end
        end
    end
end
