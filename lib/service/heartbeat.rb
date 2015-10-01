require_relative '../core/service'
require 'monitor'

class HeartBeatService < Service

  provided_features :heartbeat

  def init
    @observers = []
    @observers_monitor = Monitor.new
  end

  def start(beat_count = -1, sleep_interval = 1)
    @running = true

    while @running and (beat_count < 0 or beat_count > 0) do
        @observers_monitor.synchronize do 
            @observers.each do |observer|
                observer[0].send observer[1]
            end
        end

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
end

