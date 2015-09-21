require_relative '../core/service'
require_relative '../console/colour'
require_relative '../console'

class ConsoleHostService < Service

    provided_features :console_host

    def initialize(io_in, io_out, io_err)
        super
        @io_in = io_in
        @io_out = io_out
        @io_err = io_err
    end

    def in
        @io_in
    end

    def out
        @io_out
    end

    def err
        @io_err
    end
end

class ConsoleService < SimpleService

    required_features :framework, :console_host
    provided_features :console

    def start
        sleep 0.1 # <- wtf hack to allow asynchronous calls, Celluloid srsly?
        @running = true
        @console_host.out.puts 'Console service started'
        @console = Console.new
    end

    def prompt
        "> "
    end

    def show_prompt
        @console_host.out.print @console.prompt
    end

    def welcome
        @console_host.out.puts "#{'Toolbox'.blue} #{'RSGi'.red} 4.0"
    end

    def running?
        @running
    end

    def read_input
#        @console_host.in.gets
        @console.read_input
    end

    def process_input(raw_input)
        @console.process_input raw_input
    end
end
