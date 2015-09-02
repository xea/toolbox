require_relative 'core/service'
require_relative 'core/service_registration'
require_relative 'core/service_registry'
require_relative 'core/state'
require 'thread'
require 'monitor'
require 'pry'

class Core

    attr_reader :event_queue, :framework

    include RunState

    def initialize(system_name)
        @current_stage = []
        @service_stages = []
        @stage_monitor = Monitor.new
        @service_monitor = Monitor.new
        @event_queue = Queue.new
        @service_registry = LocalServiceRegistry.new
        @framework = Framework.new(self)

        register_service :framework, @framework, [ :framework ]
        commit_stage
    end

    def register_service(service_id, service, features)
        service_object = service.kind_of?(Class) ? service.new : service
        service_object.init

        service_registration_request = [ service_id, service, features ] 

        @stage_monitor.synchronize do
            @current_stage.insert 0, service_registration_request
        end

        service_id
    end

    def bootstrap
        commit_stage
        process_service_queue

        main_thread = Thread.current

        # TODO check if console service is available and decide what to do on the main thread
        @event_thread = Thread.new do
            event_loop(main_thread)
        end

        try_console
    end

    def shutdown
        @event_queue << :shutdown
        @event_thread.join unless @event_thread.nil?
    end

    def process_service_queue
        def process_stages(stages)
            current_stage = stages.pop

            unless current_stage.nil?
                registrations = current_stage.map do |service_registration_request|
                    @service_registry.register_service(*service_registration_request)
                end

                registrations.each do |registration|
                    start_service registration
                end

                process_stages stages
            end
        end

        @stage_monitor.synchronize do 
            process_stages @service_stages
        end

        puts "- processing finished"
    end

    def start_service(service_registration)
        service = service_registration[:service]

        puts "starting service #{service.service_id}"

        if service.state? RunState::STOPPED
            service.set_state_starting

            required_services, optional_services = [ :required_features, :optional_features ].map { |type|
                Hash[*(service.send(type).map { |feature| [ feature, @service_registry.find(feature)]}).flatten]
            }
            
            if required_services.has_value? nil
                raise "Can't start service because a mandatory feature dependency cannot be satisfied"
            else
                (required_services + optional_services).each do |feature, dependency|
                    if dependency.service.state? RunState::STOPPED
                        start_service dependency
                    end

                    proxy = ServiceProxy.consume service, self
                    service.feature_up feature, proxy
                end

                service.start
                service.set_state_started

            end
        end

        service.start
        service.set_state_started
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

# Represents the micro-service framework to the framework itself.
class Framework < Service

    provided_features :framework

    def initialize(core)
        @core = core
    end

    def start
        puts "Framework started"
    end

    def find_service
    end

    def register_service(id, service, features = nil)
        @core.register_service id, service, features
    end

    def stage(reuse_last = false)

    end
end

class TestService < Service

    required_features :framework
    provided_features :test

    def init
        puts "TestService init"
    end

    def destroy
        puts "TestService destroy"
    end

    def start
        puts "TestService start"
    end

    def stop
        puts "TestService stop"
    end

    def test
        puts "TestService test"
    end

    def framework_up(framework)
        puts "TestService framework_up"
        @framework = framework
    end
end

class HeartBeatService < Service

    provided_features :heartbeat

    def init
        @observers = []
    end

    def start
        puts "Heartbeat service starting"
        @running = true

        while @running do
            @observers.each do |observer|
                observer[0].send observer[1]
            end

            sleep 5
        end
    end

    def stop
        puts "Heartbeat service stopping"
        @running = false
    end

    def sign_up(listener, method)
        @observers << [listener, method]
    end
end

class HeartBeatListener < Service

    required_features :heartbeat

    def start
        @heartbeat.sign_up self, :beat
    end

    def beat
        puts "fthump"
    end
end
