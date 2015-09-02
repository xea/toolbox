require_relative 'core/service'
require_relative 'core/state'
require 'thread'
require 'monitor'
require 'pry'

class Core

    attr_reader :event_queue

    include RunState

    def initialize(system_name)
        @service_registration_queue = []
        @current_stage = []
        @service_stages = []
        @stage_monitor = Monitor.new
        @event_queue = Queue.new

        register_service :core, self, [ :framework ]
        commit_stage
    end

    def register_service(service_id, service, features)
        @stage_monitor.synchronize do
            @current_stage.insert 0, { id: service_id, service: service, features: features }
        end

        service_id
    end

    def start
        commit_stage
        process_service_queue

        main_thread = Thread.current

        # TODO check if console service is available and decide what to do on the main thread
        @event_thread = Thread.new do
            event_loop(main_thread)
        end

        try_console
    end

    def stop
        @event_queue << :shutdown
        @event_thread.join unless @event_thread.nil?
    end

    def process_service_queue

        def process_stages(stages)
            current_stage = stages.pop

            unless current_stage.nil?
                current_stage.each do |service_declaration|
                    # TODO start services
                end

                process_stages stages
            end
        end

        @stage_monitor.synchronize do 
            process_stages @service_stages
        end
    end

    # Close and commit the current service stage and open a new, empty stage. Services registered up to this 
    # point will be processed as one batch.
    def commit_stage
        @stage_monitor.synchronize do
            @service_stages << @current_stage unless @current_stage.empty?
            @current_stage = []
        end
    end

    def event_loop
        is_shutdown = false

        while !is_shutdown do
            message = @event_queue.pop

            case message
            when :shutdown
                is_shutdown = true
            else
                # TODO message processing here
            end
        end
    end

    def try_console
        # if console service is available
        #
    end

end


