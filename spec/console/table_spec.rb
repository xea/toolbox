require 'console/table'

RSpec.describe PrinTable do

    before :example do
        @printable = PrinTable.new
    end

    context '#print_simple_table' do
        it 'should omit headers if not present' do
        end
    end

    context '#print_raw_table' do
        it 'should omit headers if not present' do
            expect(@printable.print_raw_table(nil, [])).to eq([])
            #expect(@printable.print_raw_table(nil, [ "a" ])).to eq(["a"])
            expect(@printable.print_raw_table(nil, [ [] ])).to eq([])
            expect(@printable.print_raw_table(nil, [ [ "a" ] ])).to eq([ "a" ])
            expect(@printable.print_raw_table(nil, [ [ "a", "b" ] ])).to eq([ "a b" ])
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
end
