class Autocomplete

    attr_accessor :last

    def initialize(interpreter)
        @interpreter = interpreter
        @idx = 0
    end

    def complete(input, pos)
        @idx = 0
        @candidates = find_possible_commands input, @interpreter.modes.current_mode, pos
        @items = @candidates.collect { |c| c[:text] }

        if @items.length > 1
            status = @items.map.with_index { |item, i| @idx % @items.length == i ? item.to_s.reverse_color : item }.join(" ")

            @last = { complete: @candidates[@idx % @items.length][:complete], status: status, size: @items.length }
        elsif @items.length == 1
            @last = { complete: @candidates[0][:complete], status: nil, size: 1 } 
        else
            @last = { complete: nil, status: nil, size: 0 }
        end
    end

    def next
        @idx += 1
        step
    end

    def prev
        @idx = @idx > 0 ? @idx - 1 : @items.length - 1
        step
    end

    def step
        if @items.length > 1
            status = @items.map.with_index { |item, i|
                @idx % @items.length == i ? item.to_s.reverse_color : item
            }.join(" ")

            @last = { complete: @candidates[@idx % @items.length][:complete], status: status, size: @items.length }
        else
            @last = { complete: nil, status: nil, size: @items.length }
        end
    end

    def reset
        @idx = 0
        @candidate = nil
        @items_cache = nil
        @last = nil
    end

    def find_possible_commands(input, mode, pos)
        local_commands = mode.available_commands
        global_commands = @interpreter.modes.global_mode.available_commands

        # build a list of commands that are available from the current mode
        all_commands = local_commands + global_commands

        # active input is the part of user input before the current cursor (pos)
        active_input = input[0...pos]

        # collecting all commands with a matching signature
        matching_commands = all_commands.find_all { |cmd| cmd.signature.matches_partial? active_input, @interpreter.build_context }

        # a: force q<tab>
        # b: force <tab>

        input_parts = active_input.split

        # we check if the cursor is standing after a character or a whitespace

        offset = active_input[-1] =~ /[\S]/ ? input_parts.length - 1 : input_parts.length

        last_length = input_parts["#{active_input}a".split.length - 1].to_s.length

        c = matching_commands.collect { |cmd| cmd.signature.expand cmd.signature.pattern.split[offset], @interpreter.build_context }.flatten.uniq.find_all { |nextw| !nextw.nil? }.map { |word| { text: word, complete: word[last_length..-1] } }

        if active_input[-1] =~ /[\s]/ or input_parts.length == 0
            c
        else
            c.find_all { |i| i[:text].start_with? input_parts[-1] }
        end
    end

end
