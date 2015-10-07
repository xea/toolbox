require_relative 'mode'

class ModeDebug < BaseMode

    mode_id :debug

    register_command(:clear_history, "clear history", "Clear command history") { |history| history.clear }
    register_command(:mode_core, "core", "Enter core management mode") { |intp| intp.modes.enter_mode :core }
    register_command(:exit_mode, "exit", "Exit current mode") { |intp| intp.modes.exit_mode }
    register_command(:launch_debugger, "debugger", "Launch interactive debugger (pry)")
    register_command(:show_helpers, "show helpers", "Show table of registered helpers")
    register_command(:show_tables, "show tables", "Show table of registered data tables")

    def construct
        @mode_active = false
    end

    def post_enter
        @mode_active = true
    end

    def pre_exit
        @mode_active = false
    end

    def launch_debugger
        binding.pry
    end

    def show_helpers(intp, out)
        t = PrinTable.new
        out.puts t.print_table([ "ID", "CLASS" ], intp.context.helpers.map { |id, helper| [ id.to_s, helper.class.name ] })
    end

    def show_tables(intp, out)
        t = PrinTable.new
        out.puts t.print_table([ "TABLE ID" ], intp.context.tables.map { |id, table| [ id ] })
    end
end
