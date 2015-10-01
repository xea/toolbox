
class PrinTable

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

        def print_simple_row(row, lengths)
            fmt = lengths.map { |l| "%#{l}s" }.join(" ")
            frow = (0...lengths.length).map { |i| row[i] || "" }
            fmt % frow
        end

        # if headers are empty or not specified, we leave them out
        local_data = ((headers.nil? or headers.length == 0) ? [] : [headers]) + data
        field_count = max_field_count(data)

        if field_count > 0
            field_lengths = (0...field_count).map { |field_idx| max_field_length(local_data, field_idx) }

            local_data.map { |row| print_simple_row(row, field_lengths.map { |x| x * -1 }).gsub(/\s*$/, "")  }
        else
            []
        end
    end

    def print_raw_table(headers, data)
        result = []

        unless headers.nil?
            result << headers.join(" ")
        end

        result += data.find_all { |row| !row.nil? and row != [] }.map { |row| row.join " " }
        result
    end

    def print_db_table(headers, data)
        field_count = [ max_field_count(headers), max_field_count(data) ].max

        if field_count > 0
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
