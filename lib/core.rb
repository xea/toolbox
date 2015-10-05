require_relative 'core/service'
require_relative 'core/service_registration'
require_relative 'core/service_registry'
require_relative 'core/state'
require_relative 'service/framework'
require_relative 'service/config'
require_relative 'service/console'
require_relative 'service/heartbeat'
require_relative 'service/logger'
require 'thread'
require 'monitor'
require 'pry'

# Implements the main framework and administrative logic, eg. module wiring, dependency injection and service location.
#
# Instances of this class should not be directly exposed to modules, it's functionality should be accessed through Framework
# instances instead.
class Core

    attr_reader :event_queue, :framework, :service_registry, :system_name

    include RunState
    include Dispatcher

    # Initialise a core with the most essential services (framework and console host). 
    def initialize(system_name, pure = false)
        @system_name = system_name
        @current_stage = []
        @service_stages = []
        @stage_monitor = Monitor.new
        @service_monitor = Monitor.new
        @event_queue = Queue.new
        @service_registry = LocalServiceRegistry.new

        # Setting pure to true will keep core from registering a new framework by default
        unless pure
            # Stage 0: Framework level
            register_service :framework, Framework, self
            commit_stage

            # Stage 1: Core logger
            register_service :corelog, LoggerService
            commit_stage

            # Stage 2: Configuration service
            register_service :config, ConfigService, "config/config.yml"
            commit_stage

            # Stage 3: Console host level
            register_service :console_host, ConsoleHostService, STDIN, STDOUT, STDERR
            commit_stage
        end
    end

    def new_service(service_id, service_class, *args, &blk)
        if service_class.include? Celluloid
            @supervisor.supervise(service_id, service_class, *args, &blk)
        else
            service_class.new(*args, &blk)
        end
    end

    def register_service(service_id, service, *params)
        # Make sure we've got an initialised service object here
        service_object = service.kind_of?(Class) ? new_service(service_id, service, *params) : service
        service_object.init

        # TODO revise the data type of service registration requests but they are good as arrays for now
        service_registration_request = [ service_id, service, service_object.provided_features ] 

        @stage_monitor.synchronize do
            @current_stage << service_registration_request
        end

        service_id
    end

    # Process the currently commited stages and initialise the services in the service queue
    def bootstrap
        @framework = Celluloid::Actor[:framework]

        commit_stage
        process_service_queue

        try_console
    end

    # Initiate core shutdown. 
    def shutdown
        @event_queue << :shutdown
        @event_thread.join unless @event_thread.nil?
    end

    def process_service_queue
        def process_stages(stages)
            current_stage = stages.shift

            unless current_stage.nil?
                registrations = current_stage.map do |service_registration_request|
                    @service_registry.register_service(*service_registration_request) { |registration|
                        registration.service.set_state_resolved if has_required_dependencies? registration.service
                    }
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
    end

    def has_all_dependencies?(service)
        !((service.required_features + service.optional_features).map { |feature| service_registry.find feature }.member? nil)
    end

    def has_required_dependencies?(service)
        !(service.required_features.map { |feature| service_registry.find feature }.member? nil)
    end

    def start_service(service_registration)
        service = service_registration[:service]

        if service.state? RunState::RESOLVED
            service.set_state_starting

            required_services, optional_services = [ :required_features, :optional_features ].map { |type|
                Hash[*(service.send(type).map { |feature| [ feature, @service_registry.find(feature) ]}).flatten]
            }

            if required_services.has_value? nil
                raise "Can't start service #{service.service_id} because a mandatory feature dependency #{service.required_features} cannot be satisfied"
            else
                (required_services.merge optional_services).each do |feature, dependency|
                    unless dependency.nil?
                        if dependency.service.state? RunState::RESOLVED
                            start_service dependency
                        end

                        proxy = ServiceProxy.consume dependency.service.spawn_new(service.service_id), self
                        service.feature_up feature, proxy
                    end
                end

                service.async.start
                service.set_state_active

                # Post-activate optional dependencies
                @service_registry.find_all { |srv| srv.state == RunState::ACTIVE and srv.optional_features.find_all { |feature| service.provided_features.member? feature}.length > 0 }.each do |opt_dependency|
                    opt_dependency.service.optional_features.find_all { |feature| service.provided_features.member? feature }.each do |feature| 
                        puts "optional injection: #{feature} to #{opt_dependency.service.service_id}"
                        proxy = ServiceProxy.consume service.spawn_new(opt_dependency.service.service_id), self
                        opt_dependency.service.feature_up feature, proxy
                    end
                end
            end
        end
    end

    def stop_service(service_registration)
        service = service_registration[:service]

        if service.state? RunState::ACTIVE
            service.set_state_stopping

            # TODO optimize these below expressions
            dependant_services_req = service.provided_features.map { |feature| @service_registry.find_all { |srv| srv.required_features.member? feature } }.reduce(:+)
            dependant_services_opt = service.provided_features.map { |feature| @service_registry.find_all { |srv| srv.optional_features.member? feature } }.reduce(:+)

            dependant_services_req.each do |dep_service|
                stop_service(dep_service)
            end

            dependant_services_opt.each do |dependant|
                dependant.optional_features.find_all? { |dep_feature| service.provided_features.member? dep_feature }.each { |opt_feature| dependant.feature_up opt_feature, nil  }
            end

            service.stop

            if has_required_dependencies?(service)
                service.set_state_resolved
            else
                service.set_state_installed
            end
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

    def event_loop(main_thread = nil)
        is_shutdown = false

        while !is_shutdown do
            message = @event_queue.pop.to_sym

            case message
            when :shutdown
                is_shutdown = true
                main_thread.raise("shutdown!") unless main_thread == Thread.current
            else
                # TODO message processing here
            end
        end
    end
	
    # TODO deal with concurrent/subsequent invocations
    def try_console
        # if console service is available

        console = @framework.service :console
        
        if console.nil?
            # No console service present, looping on main thread
            event_loop(main_thread)
        else
            # Console service found, starting console on the foreground event loop on background thread
            main_thread = Thread.current

            begin
                @event_thread = Thread.new do
                    event_loop(main_thread)
                end

                run_console console
            rescue => e
                puts "Exception caught (#{e}) on main thread, shutting down"
                puts e.backtrace.first
            end
        end
    end

protected

    def run_console(console)
        console.welcome

        while console.running? do
            console.show_prompt
            raw_input = console.read_input
            host_event = console.process_input raw_input
            if host_event.kind_of? Symbol
                @event_queue << host_event unless host_event.nil? if host_event.kind_of? Symbol
            end
        end
    end
end

