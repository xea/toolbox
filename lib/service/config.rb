require_relative '../core/service'
require_relative '../console/mode'
require 'monitor'
require 'yaml'

class ConfigService < Service

    optional_features :logger, :console
    provided_features :config 

    def initialize(filename = nil)
        super
        @source = filename
        @config_monitor = Monitor.new
    end

    def stop
        @console.unregister_mode ConfigMode
    end

    def spawn_new(spawn_id = nil)
        reload
        ConfigProxy.new spawn_id, self
    end

    def reload
        if File.exist? @source
            @config_monitor.synchronize do
                @cached_data = Psych.load_file @source || {}
            end
        else
            @config_monitor.synchronize do
                @cached_data = {}
            end
        end
    end

    def get(spawn_id, key)
        @config_monitor.synchronize do
            spawn_cfg = @cached_data[spawn_id] || {}
            spawn_cfg[key]
        end
    end

    def set(spawn_id, key, value)
        @config_monitor.synchronize do
            spawn_cfg = @cached_data[spawn_id] || {}
            spawn_cfg[key] = value
            @cached_data[spawn_id] = spawn_cfg

            unless @source.nil?
                File.open(@source, "w+") do |file|
                    file.write(@cached_data.to_yaml)
                end
            end
        end
    end

    def dump
        reload
        Psych.dump @cached_data
    end

    def feature_up(feature, service)
        case feature
        when :logger
            @logger = service
        when :console
            if service.nil?
                @console.unregister_mode ConfigMode
                @console = nil
            else
                @console = service
                @console.register_helper :config, self
                @console.register_mode ConfigMode
            end
        end
    end
end

class ConfigProxy < SimpleService

    def initialize(spawn_id, service)
        super
        @spawn_id = spawn_id
        @service = service
    end

    def [](key)
        @service.get(@spawn_id, key)
    end

    def []=(key, value)
        @service.set(@spawn_id, key, value)
    end
end

class ConfigMode < BaseMode

    mode_id :config
    access_from :debug, "config", "Enter configuration mode"

    register_command(:exit_mode, "exit", "Exit current mode") { |intp| intp.modes.exit_mode }
    register_command(:dump_config, "dump", "Dump configuration to screen") do |config|
        puts config.dump
    end

end
