require 'console/terminal'

RSpec.describe Terminal do

    class TestTerminal

        attr_accessor :next_input

        def initialize
            @next_input = ""
        end

        def puts(*args)
            args.join("\n") + "\n"
        end

        def print(*args)
            args.join("")
        end

        def gets(*args)
            @next_input
        end
    end

    before :example do
        @in = TestTerminal.new
        @out = TestTerminal.new
        @err = TestTerminal.new
        @term = Terminal.new @in, @out, @err
    end

    context '#puts' do
        it 'should pass data accordingly to how it received it' do
            expect(@term.puts "").to eq("\n")
            expect(@term.puts "\tcontrol characters\r\n").to eq("\tcontrol characters\r\n\n")
        end

        it 'should concatenate lines when multiple lines are passed' do
            expect(@term.puts "first", "second").to eq("first\nsecond\n")
        end
    end

    context "#print" do
        it 'should not concatenate lines when multiple lines are passed' do
            expect(@term.print 'foo', 'bar').to eq('foobar')
        end
    end

    context 'shift_line' do
        it 'shifts one line by default' do
            expect(@term.shift_line).to eq("\n\r")
        end

        it 'shifts the provided number of lines when passed' do
            expect(@term.shift_line 0).to eq("")
            expect(@term.shift_line 1).to eq("\n\r")
            expect(@term.shift_line 2).to eq("\n\r\n\r")
            expect(@term.shift_line 3).to eq("\n\r\n\r\n\r")
        end
    end
end
