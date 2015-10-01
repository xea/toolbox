require 'console/history'

RSpec.describe History do

    TEST_PATH = "_test.history"

    before :example do
        history = File.open TEST_PATH, "a+"
        history.puts "foo"
        history.puts "bar"
        history.puts "foobar"
        history.close
        @history = History.new 
        @history_f = History.new TEST_PATH
    end

    context '#initialise' do
        it 'should initialise an empty history when no filename was specified' do
            expect(@history.current).to eq([-1, nil])
        end

        it 'should initialise history from input file when a path is specified' do
            expect(@history_f.current).to eq([-1, nil])
            expect(@history_f.prev).to eq([0, 'foobar'])
            expect(@history_f.prev).to eq([1, 'bar'])
            expect(@history_f.prev).to eq([2, 'foo'])
        end
    end

    context '#append' do
        it 'should insert new input to the start of history' do
            @history.append "foo"
            expect(@history.prev).to eq([0, 'foo'])
        end

        it 'should rewind to the beginning of history' do
            @history.append 'foo'
            expect(@history.current).to eq([-1, nil])
        end
    end

    context '#prev' do
        it 'should step back in history one step' do
        end

        it "shouldn't step beyond the last element in history" do
        end
    end

    context '#next' do
        it 'should step forward in history' do
            @history.append '1'
            @history.append '2'
            @history.append '3'
            @history.append '4'
            @history.append '5'

            @history.prev
            @history.prev
            @history.prev
            @history.prev
            expect(@history.next).to eq([2, '3'])
            expect(@history.next).to eq([1, '4'])
            expect(@history.next).to eq([0, '5'])
        end

        it "should not step past the first element in history" do
            @history.append '1'
            @history.append '2'
            @history.append '3'
            @history.append '4'
            @history.append '5'

            @history.prev
            expect(@history.next).to eq([-1, nil])
            expect(@history.next).to eq([-1, nil])
            expect(@history.next).to eq([-1, nil])
            expect(@history.next).to eq([-1, nil])
        end
    end

    context '#current' do
    end

    context '#rewind' do
        it 'should reset the pointer to the beginning of history' do
            @history.append '1'
            @history.append '2'
            @history.append '3'
            @history.append '4'
            @history.prev
            @history.prev
            @history.prev
            @history.rewind
            expect(@history.current).to eq([-1, nil])
        end
    end

    context '#reset' do
    end

    context '#clear' do
    end
end
