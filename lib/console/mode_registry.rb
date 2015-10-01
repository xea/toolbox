require_relative "mode"

# Maintains a registry of console modes. Modes are divided into two types: regular modes and global modes. 
#
# Currently, ModeRegistry stores only one global mode instance at a time whereas it can store an arbitrary
# number of regular modes. The difference between the two types is that regular modes are only availabe if
# they are active whereas global modes are available always.
class ModeRegistry

    def initialize
        @modes = {}
        @mode_stack = []
        @global_mode = nil
    end

    # Register a new regular mode class.
    def register_mode(mode)
        unless mode.nil? or !mode.kind_of? Class or !mode.ancestors.member? BaseMode
            @modes[mode.id] = mode
        else
            raise "Can't register nil as mode"
        end
    end

    # Unregister a previously registered mode class
    def unregister_mode(mode)
	if @modes.has_key? mode.id
            if current_mode.mode_id == mode.id
		exit_mode
	    end
            @modes.delete mode.id
	end
    end

    # Register a new global mode class, replacing the previous instance if there was one.
    def register_global_mode(mode)
        unless mode.nil?
            register_mode(mode)
            @global_mode = mode.new
        else
            raise "Can't register nil as global mode"
        end
    end

    # Enter the mode identified by mode_id if it exist or raise an error if it doesn't exist.
    def enter_mode(mode_id)
        if has_mode? mode_id
            mode = @modes[mode_id].new
            @mode_stack << mode
            mode.post_enter
        else
            raise "Selected mode (#{mode_id}) can't be found"
        end
    end

    # Exit current mode if there are more than two modes available.
    def exit_mode
        @mode_stack.pop.pre_exit unless @mode_stack.length < 2
    end

    # Tells if a mode identified by mode_id has been registered
    def has_mode?(mode_id)
        @modes.has_key? mode_id
    end

    # Return the mode identified by mode_id
    def mode(mode_id)
        @modes[mode_id]
    end

    # Return the currently selected interpreter mode or nil if no modes are selected
    def current_mode
        @mode_stack.last
    end

    # Return the current global mode or nil if there's none
    def global_mode
        @global_mode
    end

    # Return a list of currently active modes, ie. the currently selected mode (if any) 
    # plus the current global mode (if any)
    def active_modes
        modes = []

        if !current_mode.nil?
            modes << current_mode
        end

        if !global_mode.nil?
            modes << global_mode
        end

        modes
    end

    def current_accessors
        @modes.map { |mode_id, mode| mode.traits[:mode_accessors].find_all { |accessor| accessor[:parent] == current_mode.mode_id } }.flatten.map { |accessor| accessor[:command] }
    end

end
