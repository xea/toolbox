require_relative "mode"

# Default global mode for providing commands available throughout the whole framework.
class ModeGlobal < BaseMode
    mode_id :global

    tables({
    })

    register_command(:quit_app, "quit", "Immediately quit application") { |intp| intp.quit }
    register_command(:show_help, "help", "Show help about available commands")

    # Debug mode is allowed anywhere in the shell
    register_command(:mode_debug, "debug", "Enter debug mode", scope(true) { |intp| intp.modes.current_mode.mode_id != :debug }) { |intp| intp.modes.enter_mode :debug }

    # This command is generated when other commands can't be assigned to the current request
    def command_not_found
        Command.new(:not_found, "", "") { puts "not found" }
    end

    def show_help(intp, out)
        pt = PrinTable.new
        local_cmd, global_cmd = intp.generate_help
        out.puts pt.print(["PATTERN", "DESCRIPTION"], local_cmd) unless local_cmd.empty?
        out.puts pt.print(["PATTERN", "DESCRIPTION"], global_cmd) unless global_cmd.empty?
    end
end
