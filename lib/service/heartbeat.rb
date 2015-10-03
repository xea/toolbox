require_relative '../core/service'
require_relative '../console/mode'
require 'monitor'

class HeartBeatService < Service

    provided_features :heartbeat

    attr_reader :counter

    def init
        @counter = 0

        @observers = []
        @observers_monitor = Monitor.new
    end

    def start(beat_count = -1, sleep_interval = 5)
        @running = true

        while @running and (beat_count < 0 or beat_count > 0) do
            @observers_monitor.synchronize do 
                @observers.each do |observer|
                    observer[0].send observer[1]
                end
            end

	    @counter += 1

            sleep sleep_interval
            beat_count -= 1 if beat_count > 0
        end
    end

    def stop
        @running = false
    end

    def subscribe(listener, method)
        @observers_monitor.synchronize do
            @observers << [listener, method]
        end
    end

    def unsubscribe(listener)
        @observers_monitor.synchronize do
            @observers.find_all { |i| i.member? listener }.each { |candidate| @observers.delete candidate }
        end
    end
end

class HeartBeatListener < Service

    attr_accessor :counter

    required_features :heartbeat
    optional_features :console

    def start
        @heartbeat.subscribe self, :beat
        @counter = 0
    end

    def stop
        @heartbeat.unsubscribe self
    end

    def beat(loud = false)
        @counter += 1

        puts '[FTHUMP]' if loud
    end

    def feature_up(feature, service)
        case feature
        when :heartbeat
            @heartbeat = service
        when :console
            if service.nil? 
                @console.unregister_mode(HeartBeatMode)
                @console = nil
            else
                @console = service
                @console.register_mode(HeartBeatMode)
            end
        end
    end
end

class HeartBeatMode < BaseMode

	mode_id :heartbeat
	access_from :debug, "heartbeat", "Enter heartbeat management mode"

	register_command(:count_heartbeat, "count", "Show current heartbeat count")
	register_command(:exit_mode, "exit", "Exit current mode") { |intp| intp.modes.exit_mode }
	register_command(:force_unregister, "unregister", "WTF") { |framework| framework.service(:console).unregister_mode(HeartBeatMode) }

	def count_heartbeat(out, framework)
		service = framework.service(:heartbeat)
		count = service.counter unless service.nil?
		out.puts "Current heartbeat count: #{count}"
	end
end
