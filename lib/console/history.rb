# Represents a linear history log 
class History

    def initialize(filename = nil)
        reset filename
    end

    # Moves the current history pointer to the previous element (that is one step further
    # in the past) and returns the newly pointed element. 
    def prev
        @history_idx += 1 if @history_idx < @history.length - 1
        current
    end

    # Moves the current history pointer to the next element (thaat is one step closer
    # to the presetn) and returns the newly pointed element
    def next
        @history_idx -= 1 if @history_idx > -1
        current
    end

    # Returns the currently pointed element from the history along with it's id
    def current
        if @history_idx < 0
            [ @history_idx, nil ]
        else
            [ @history_idx, @history[@history_idx] ]
        end
    end

    # Resets the history pointer to the buffer element (that is the one before the first stored
    # history element)
    def rewind
        @history_idx = -1
    end

    def append(input)
        unless input.nil? or input.to_s.length == 0 or input.to_s =~ /^[\s]*$/
            @history.insert 0, input.to_s 
            @backend.puts input unless @backend.nil?
        end
    end

    def last_input
        @history[0]
    end

    def reset(filename)
        @history = []
        @history_idx = -1

        unless filename.nil? or !File.exists? filename
            @history = File.readlines(filename).map { |l| l.rstrip }.reverse
        end

        @backend = File.open filename, "a+"
    end

    def clear
        @backend.close
        File.delete @backend.path
        reset @backend.path
    end
end

