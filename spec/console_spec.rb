require 'console'

RSpec.describe Console do

    class ConsoleTestTerminal

        attr_reader :output
        attr_writer :input

        def initialize
            @output = []
            @input = []
            @real_terminal = Terminal.new
            @statusbar = nil
        end

        def gets(&code)
            input = "things\n"
            input.chars.map { |c| code.yield c }
            #code.yield(@real_terminal.key_for "c")
        end

        def key_for(e)
            @real_terminal.key_for e
        end

        def puts(*args)
            @output += args
        end

        def print(*args)
            @output += args
        end

        def clear_statusbar(e)
            @statusbar = nil
        end
    end

    before :example do
        @terminal = ConsoleTestTerminal.new
        @console = Console.new @terminal
    end

    context "#initialize" do
        it "should initialise an empty console" do
            #TODO
        end
    end

    context "#welcome" do
        it "should print a welcome message to the terminal" do
            @console.welcome
            expect(@terminal.output.length > 0).to be_truthy
        end
    end

    context "#read_input" do
        it "should do stuff" do
            input = @console.read_input
            binding.pry
            #expect(input).to be_nil
        end
    end
end
