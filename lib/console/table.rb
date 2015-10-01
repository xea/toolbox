
class PrinTable

    def initialize(style = :simple)
        @default_style = style
    end

    # TODO add pagination

    def print(headers, data, style = @default_style)
        a_headers = headers || @header_cache
        a_data = data || @data_cache

        result = print_table(a_headers, a_data, style)

        @header_cache = a_headers
        @data_cache = a_data

        result
    end

    def print_table(headers, data, style = nil)
        case style
        when :raw
            print_raw_table(headers, data)
        when :simple
            print_simple_table(headers, data)
        when :db
            print_db_table(headers, data)
        else
            print_simple_table(headers, data)
        end
    end

    def print_simple_table(headers, data)

        print_fmt_table(headers, data, { v: " ", sh: false, pl: 0, pr: 0 })
    end

    def print_raw_table(headers, data)
        result = []

        unless headers.nil?
            result << headers.join(" ")
        end

        result += data.find_all { |row| !row.nil? and row != [] }.map { |row| row.join " " }
        result
    end

    def print_fmt_table(headers, data, fmt = {})
        # pl - padding left, pr - padding right, sh: separate headers
        default_fmt = { node: "+", h: "-", v: "|", pl: 1, pr: 1, sh: true }
        fmt = default_fmt.merge fmt

        def print_fmt_row(row, lengths, deco)
            fmt = lengths.map { |l| "#{' ' * deco[:pl]}%#{l}s#{' ' * deco[:pr]}" }.join(deco[:v])
            frow = (0...lengths.length).map { |i| row[i] || "" }
            (fmt % frow).gsub(/\s*$/, "")
        end

        def print_fmt_separator(lengths, deco)
            fmt = lengths.map { |l| "#{deco[:h] * deco[:pl]}%#{l}s#{deco[:h] * deco[:pr]}" }.join(deco[:node])
            frow = lengths.map { |l| deco[:h] * l }
            fmt % frow
        end

        # if headers are empty or not specified, we leave them out
        local_headers = ((headers.nil? or headers.length == 0) ? [] : [headers])
        local_data = local_headers + data
        field_count = max_field_count(local_data)

        if field_count > 0
            field_lengths = (0...field_count).map { |field_idx| max_field_length(local_data, field_idx) }

            result = []
            if local_headers.length > 0
                result << print_fmt_row(headers, field_lengths.map { |x| x * -1 }, fmt)
                result << print_fmt_separator(field_lengths, fmt) if fmt[:sh]
            end

            result += data.map { |row| print_fmt_row(row, field_lengths.map { |x| x * -1 }, fmt) }
        else
            []
        end
    end


    def max_field_count(data)
        if data.nil? or !data.kind_of?(Array) 
            0
        else
            data.collect { |row| (row || []).length }.max || 0
        end
    end

    def max_field_length(data, idx)
        data.map { |row| row[idx].to_s.length }.max || 0
    end
end
