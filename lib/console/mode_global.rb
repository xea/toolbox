require_relative "mode"

class ModeGlobal < BaseMode
    mode_id :global

    tables({
    })

    register_command(:quit_app, "quit", "Immediately quit application") { |intp| intp.quit }

    # Debug mode is allowed anywhere in the shell
    register_command(:mode_debug, "debug", "Enter debug mode", scope(true) { |intp| intp.modes.current_mode.mode_id != :debug }) { |intp| intp.modes.enter_mode :debug }

    def construct
    end

    # This command is generated when other commands can't be assigned to the current request
    def command_not_found
        Command.new(:not_found, "", "") { puts "not found" } 
    end

end

