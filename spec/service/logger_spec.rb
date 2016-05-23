require 'service/logger'

RSpec.describe LoggerService do

    class TestTarget < IO

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

    context "#info" do
        it "should send a log message to the info logger" do
            #TODO implement this
        end
    end

end
