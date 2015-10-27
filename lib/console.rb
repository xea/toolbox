require_relative "core/service"
require_relative "console/terminal"
require_relative "console/colour"
require_relative "console/buffer"
require_relative "console/history"
require_relative "console/interpreter"
require_relative "console/autocomplete"

require_relative "console/mode_core"

# Enables user-interaction with the framework via keyboard inputs
class Console 

    attr_reader :interpreter

    def initialize(terminal = Terminal.new)
        @term = Terminal.new
        @buffer = LineBuffer.new
        @history = History.new ".toolbox.history"
        @interpreter = Interpreter.new 
        @autocomplete = Autocomplete.new @interpreter
        @running = false

        @interpreter.register_helper :history, @history
    end

    # Initialises the terminal and launches the CLI console
    def start
        @running = true

     #   welcome
      #  main_loop
    end

    def stop
        @running = false
    end

    # Prints a nice, warm welcoming banner introducing ourselves to the user.
    def welcome
		@term.puts "Welcome to " +  "TOOLBOX".bold.green + " #{'3.0'.blue}"
        @term.puts
        @term.puts "Known bugs and other #{'TODO'.green} items:"
    end
    
    # Returns the current cursor offset. This might seem 
    def current_position
        gen_prompt.no_colors.length + @buffer.idx
    end

    def main_loop
        while @running do
            prompt
            raw_input = read_input
            process_input raw_input
        end
    end

    # Displays a prompt message to the user containing the most inportant information
    # about the current context, such as the hostname of the connected server, username, etc.
    def prompt
        @term.print gen_prompt
    end

    def gen_prompt
        mode_str = "#{@interpreter.modes.current_mode.mode_id.to_s.cyan}"
        "(#{mode_str}) "
    end

    def read_input
        @term.gets do |c|
            case @term.key_for c
            when :key_up
                history_prev
            when :key_down
                history_next
            when :key_left
                @term.print @buffer.cursor_left
            when :key_right
                @term.print @buffer.cursor_right
            when :key_delete
                @term.print @buffer.delete
            when :key_alt_del
                @term.print @buffer.delete
            when :key_backspace
                @term.print @buffer.delete_back
            when :key_tab
                autocomplete_input @buffer.to_s
                @last_tab = true
            when :key_shift_tab
                autocomplete_input @buffer.to_s, true
                @last_tab = true
            when :key_ctrl_c
                @logger.error "Caught Ctrl-C, bailing out"
                exit 0
            when :key_return
                @autocomplete.reset
                s = @buffer.to_s
                @buffer.clear
                @term.clear_statusbar gen_prompt.length
                @term.shift_line
                @history.rewind
                @last_tab = false
                return s
            when :key_question_mark 
                if @buffer.idx == 0
                    help = generate_help
                    @term.clear_statusbar current_position
                    @term.statusbar help, current_position
                else
                    @term.print @buffer.type c
                end
            else
                @term.print @buffer.type c
            end

            case @term.key_for c
            when :key_tab
                @last_tab = true
            when :key_shift_tab
                @last_tab = true
            when :key_question_mark
            else
                @term.clear_statusbar current_position
                @last_tab = false
            end
        end
    end

    def history_next
        prev_id = @history.current[0]
        if prev_id == 0
            @history.next
            @term.print @buffer.pop_state
        elsif prev_id > 0
            item = @history.next[1]
            @term.print @buffer.set(item.to_s, item.to_s.length)
        end
    end

    # Steps one item back in history and updates console
    def history_prev
        prev_id = @history.current[0]
        id, item = @history.prev
        if id == 0 and prev_id == -1
            @buffer.push_state
        end
        @term.print @buffer.set(item.to_s, item.to_s.length)
    end

    def generate_help
        def gen_help(commands, width)
            fmt = "    %-#{width}s     %s"
            commands.map { |msg| fmt % msg }
        end

        local_header = [ " Local commands" ]
        local_commands = (@interpreter.modes.current_mode.available_commands + @interpreter.modes.current_accessors).map { |cmd| [ cmd.signature.to_readable, cmd.description ] }

        global_header = [ " Global commands" ]
        global_commands = @interpreter.modes.global_mode.available_commands.map { |cmd| [ cmd.signature.to_readable, cmd.description ] }

        max_sig_length = (local_commands + global_commands).collect { |m| m[0].length }.max || 0
        max_sig_length = 7 if max_sig_length < 7

        local_help = gen_help(local_commands, max_sig_length).sort
        global_help = gen_help(global_commands, max_sig_length).sort

        separator = [ "" ]

        (local_header + local_help + separator + global_header + global_help).join "\r\n"
    end

    def autocomplete_input(input, step_back = false)
        @term.print @buffer.delete_back(@autocomplete.last[:complete].to_s.length) if @last_tab and @autocomplete.last[:size] > 1

        if step_back
            completed = @last_tab ? @autocomplete.prev : completed = @autocomplete.complete(@buffer.to_s, @buffer.idx)
        else
            completed = @last_tab ? @autocomplete.next : completed = @autocomplete.complete(@buffer.to_s, @buffer.idx)
        end

        unless completed[:status].nil?
            @term.clear_statusbar current_position unless @last_tab
            @term.statusbar completed[:status], current_position
        end

        unless completed[:complete].nil?
            @term.print @buffer.print(completed[:complete])
        end
    end

    def process_input(input)
        @history.append input
        @interpreter.process input
    end
end
