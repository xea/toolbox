require 'io/console'

# Provides an easy-to-use interface over the raw terminal allowing clients reading from and 
# writing to the raw terminal conviniently.
class Terminal

    KEYTABLE = {
        key_up:         "\e[A",
        key_down:       "\e[B",
        key_right:      "\e[C",
        key_left:       "\e[D",
        key_delete:     "\004",
        key_home:       "\e[1~",
        key_alt_del:    "\e[3~",
        key_end:        "\e[4~",
        key_page_up:    "\e[5~",
        key_page_down:  "\e[6~",
        key_return:     "\r",
        key_tab:        "\t",
        key_shift_tab:  "\e[Z",
        key_line_feed:  "\n",
        key_backspace:  "\177",
        key_ctrl_c:     "\u0003",
        key_question_mark: "?",
        key_any:        /^.$/
    }

    def initialize
        @echo = true
    end

    def puts(*args)
        $stdout.puts(*args) if @echo
    end

    def print(*args)
        $stdout.print(*args) if @echo
    end

    def shift_line(n = 1)
        print("\n\r" * n.to_i)
    end
    
    # Turns the given input value (usually a key or escape sequence) into a symbol describing 
    # the characteristics of the type of the key
    def key_for(value)
        KEYTABLE.key(value)
    end

    # Tries to read a line from the standard input allowing a callback to be called after
    # each keystroke. This may be used to implement tab-completion or other interactive features
    def gets(&callback)
        STDIN.echo = false
        STDIN.raw!

        while true
            key = get_key

            callback.call(key) unless callback.nil?
        end
    ensure
        STDIN.cooked!
    end

    # Reads one keypress from the standard input. Note that this is not equivalent
    # to reading one byte, because escape sequences (such as F-keys, home, end, page up, etc)
    # constist of more bytes
    def get_key
        char = get_char

        if char == "\e"
            a = get_char 
            b = get_char 
            c = b =~ /[0-9]/ ? get_char : ""

            char = char + a + b + c
        end

        char
    end

    # Reads a single character from the standard input.
    def get_char
        input = STDIN.getc.chr
        if input =="\e" then
            input << STDIN.read_nonblock(3) rescue nil
            input << STDIN.read_nonblock(2) rescue nil
        end

        input
    end

    def statusbar(status, reset_position = 0, force_up = 0)
        shift_line
        print status
        print "\r"
        #print KEYTABLE[:key_up] * (1 + (status.length / winsize[1]) + status.count("\n"))
        lines = status.split(/\r\n|\n|\r/)
        width = winsize[1]
        up_count = lines.length + lines.map { |l| l.length / width }.inject { |sum, x| sum + x }
        print KEYTABLE[:key_up] * up_count
        print KEYTABLE[:key_right] * reset_position
        @rpos = reset_position
        @rstat = status
    end

    def clear_statusbar(reset_position = @rpos)
        unless @rstat.nil?
            statusbar(@rstat.no_colors.gsub(/[^\r\n]/m, " "), reset_position)
            @rstat = nil
        end
    end

    def get_cursor_position
        print "\e[6n"
        c = ""
        while c[-1] != 'R' 
            c += $stdin.getc
        end

        if c =~ /^.\[([0-9]+);([0-9]+)R/
            [ $1, $2 ]
        else
            [ -1, -1 ]
        end
    end
end

