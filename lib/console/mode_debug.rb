require_relative 'mode'

class ModeDebug < BaseMode

    mode_id :debug

    register_command(:clear_history, "clear history", "Clear command history") { |history| history.clear }
    register_command(:mode_core, "core", "Enter core management mode") { |intp| intp.modes.enter_mode :core }
    register_command(:exit_mode, "exit", "Exit current mode") { |intp| intp.modes.exit_mode }

    def construct
        @mode_active = false
    end

    def post_enter
        @mode_active = true
    end

    def pre_exit
        @mode_active = false
    end

end
