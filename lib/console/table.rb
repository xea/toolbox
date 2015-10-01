
class PrinTable
    def print_table(headers, data, style = nil)
    end

    def print_simple_table(headers, data)
        field_count = [ max_field_count(headers), max_field_count(data) ].max

        if field_count > 0
            (0..field_count).each do |field_idx|
            end
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

    # headers = [], data = [ [] ]
    def print_db_table(headers, data)
    end

    def max_field_count(data)
        if data.nil? or !data.kind_of?(Array) 
            0
        else
            data.collect { |row| row.length }.max || 0
        end
    end
end
