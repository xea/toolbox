require_relative 'context'

class Signature
    # exit|quit
    # show :id
    # show $queuetype
    # show #rowid
    # > #attributes

    attr_reader :pattern

    def initialize(pattern)
        @pattern = pattern
    end

    # Expands the given command pattern on the given context and generates a signature
    # that can be applied to any user input
    def expand(pattern, ctx = nil)

        case pattern.to_s[0]
        when nil
            []
        when ":"
            nil
        when "$"
            table = {}

            if ctx.kind_of? Hash
                table = ctx[pattern[1..-1].to_sym]
            elsif ctx.kind_of? CommandContext
                table = ctx.tables[pattern[1..-1].to_sym] || {}
            end

            if table.kind_of? Array
                table
            else
                # Hash or Expandable
                table.keys
            end
        when "#"
            obj = {}

            if ctx.kind_of? Hash
                obj = ctx[:current_object] || ctx[:scope]
            elsif ctx.kind_of? CommandContext
                obj = ctx.vars[:current_object] || ctx.mode_args[:scope]
            end

            if !ctx.nil? and !obj.nil?
                if obj.respond_to? :attributes
                    obj.attributes.keys
                elsif obj.respond_to? :keys
                    obj.keys.map { |k| k.to_s }
                else
                    (obj.methods - Object.methods).map { |m| m.to_s }
                end
            end
        else
            [ pattern ]
        end
    end

    def matches?(input, ctx = nil)
        re = to_regexp(@pattern, ctx)
        input =~ re
    end

    def to_regexp(match_pattern, context = nil)
    #    pattern = match_pattern.gsub(/ [$:#][\S]+([?])/, "([\\s]+[\\S]+)?")
        p1 = match_pattern.gsub(/[\s]*[$:#][\w]+[?]/, "[\\s]?([\\S]+)?")
        p2 = p1.gsub(/[$:#][\w]+/, "([\\S]+)")
        p3 = p2.gsub(/[*][\S]+/, "(.*)")
        Regexp.new "^#{p3}[+!]?$"
    end

    def matches_partial?(input, ctx = nil)
        pattern_parts = @pattern.split
        input_parts = input.split
        ends_on_word = input[-1] =~ /[\S]/

        if pattern_parts == 0
            # if the pattern has no parts then it was erroneously defined: no match
            return false
        elsif input_parts.length == 0
            # if the user has provided nothing or only whitespaces then every command matches
            return true
        elsif input_parts.length > pattern_parts.length
            # the user has provided more input than that this command supports: no match
            return false
        elsif ends_on_word
            # the cursor is standing right behind a word: completing the previous word

            # force qu<tab>
            # input_part_id = 1

            unless strict_head_check pattern_parts, input_parts, ctx

                # the previously entered input isn't matching: no match
                return false
            end

            # the previously entered input is matching so far, checking remaining piece
            # or we're standing on the first word

            # checking last word
            return expand_pattern(input_parts[-1], pattern_parts[input_parts.length - 1], ctx)
        else
            # the cursor is standing right behind a whitespace: completing the next word

            unless strict_head_check pattern_parts, input_parts + [""], ctx

                # the previously entered input isn't matching: no match
                return false
            end

            return expand_pattern(nil, pattern_parts[input_parts.length], ctx)
        end
    end

    def strict_head_check(pattern_parts, input_parts, ctx = nil)
        input_part_id = input_parts.length - 1

        # We're not standing on the first word, checking previous parts
        strict_match_pattern = pattern_parts[0...input_part_id].join(" ")

        partial_input = input_parts[0...input_part_id].join(" ")
        partial_input =~ to_regexp(strict_match_pattern, ctx) or input_part_id == 0
    end

    def expand_pattern(input_part, pattern_part, ctx = nil)
        expanded = expand(pattern_part, ctx)

        input_pattern = Regexp.new "^#{input_part.to_s}.*[+!]?$"

        if input_part.nil? and !pattern_part.nil?
            true
        else
            expanded.nil? or (expanded.find_all { |item| item =~ input_pattern }.length > 0)
        end

    end

    def to_readable
        pattern.to_s
    end

    def extract(input)
		arg_ids = @pattern.scan(/[$:#*][\S]+/)

        if input =~ to_regexp(@pattern, nil)
            # params holds the incoming arguments for the captures
            Hash[*(arg_ids.zip($~.captures).flatten)]
        else
            {}
        end
    end
end

class DynamicSignature
end
