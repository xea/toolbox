require 'console/table'

RSpec.describe PrinTable do

    before :example do
        @printable = PrinTable.new
    end

    context '#print_simple_table' do
        it 'should omit headers if not present' do
            headers, data = [nil, [[1, 2], [3, 4]]]
            expect(@printable.print_simple_table(headers, data)).to eq([ "1 2", "3 4" ])
            headers, data = [[], [[1, 2], [3, 4]]]
            expect(@printable.print_simple_table(headers, data)).to eq([ "1 2", "3 4" ])
        end

        it 'should generate a well idented table' do
            headers, data = [ [ "Key", "Value" ], [ 
                [ "fruit", "apple" ], [ "car", "porsche" ]
            ] ]
            expect(@printable.print_simple_table(headers, data)).to eq([ "Key   Value", "fruit apple", "car   porsche" ])
        end
    end

    context '#print_raw_table' do
        it 'should omit headers if not present' do
            expect(@printable.print_raw_table(nil, [])).to eq([])
            expect(@printable.print_raw_table(nil, [ [] ])).to eq([])
            expect(@printable.print_raw_table(nil, [ [ "a" ] ])).to eq([ "a" ])
            expect(@printable.print_raw_table(nil, [ [ "a", "b" ] ])).to eq([ "a b" ])
            tabledata = [
                [ "alma", "korte" ], [ "repa", "cukor" ]
            ]
            expect(@printable.print_raw_table(nil, tabledata)).to eq(["alma korte", "repa cukor"])
        end
    end

    context '#max_field_count' do
        it 'should return zero when data is omitted' do
            expect(@printable.max_field_count(nil)).to eq(0)
        end

        it 'should return the maximum number of fields found in data' do
            expect(@printable.max_field_count([])).to eq(0)
            expect(@printable.max_field_count([[]])).to eq(0)
            expect(@printable.max_field_count([[1]])).to eq(1)
            expect(@printable.max_field_count([[1], [2]])).to eq(1)
            expect(@printable.max_field_count([[1], [2, 3]])).to eq(2)
            expect(@printable.max_field_count([[1, 1, 2], []])).to eq(3)
        end
    end

    context '#max_field_length' do
        it 'should return the maximum length of fields' do
            expect(@printable.max_field_length([[]], 0)).to eq(0)
            expect(@printable.max_field_length([["1"]], 0)).to eq(1)
            expect(@printable.max_field_length([["1"]], 1)).to eq(0)
            expect(@printable.max_field_length([["123", "1234"], ["1", "123"]], 0)).to eq(3)
            expect(@printable.max_field_length([["1"], ["123", "1"]], 0)).to eq(3)
        end
    end
end
