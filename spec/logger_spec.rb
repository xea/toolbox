require "logger"

RSpec.describe LoggerService do

    class TestTarget

        attr_reader :counter, :buffer

        def initialize
            @counter = 0
            @buffer = []
        end

        def puts(*args)
            @counter += 1
            args.each { |arg| @buffer << arg }
        end

        def print(*args)
            @counter += 1
            args.each { |arg| @buffer << arg }
        end

    end

    before (:example) do
        @target = TestTarget.new
        @logger = LoggerService.new @target
    end

    context "#initialize" do
        it "should use the standard output unless it is told otherwise" do
            expect { LoggerService.new }.to_not raise_error
        end

        it "should not accept a target that is not writeable" do
            expect { LoggerService.new "a string" }.to raise_error("Can't accept non-writeable target")
        end

        it "should accept a target and use that target for subsequent logging" do
            @logger.info "test message" 
            expect(@target.buffer.length).to eq(1)
            expect(@target.buffer.last.end_with? "test message").to be(true)
        end
    end

end
