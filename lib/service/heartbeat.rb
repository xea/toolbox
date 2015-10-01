require_relative '../core/service'

class HeartBeatService < Service

  provided_features :heartbeat

  def init
    @observers = []
  end

  def start(beat_count = -1, sleep_interval = 5)
    @running = true

    while @running and (beat_count < 0 or beat_count > 0)do
      @observers.each do |observer|
        observer[0].send observer[1]
      end

      sleep sleep_interval
      beat_count -= 1 if beat_count > 0
    end
  end

  def stop
    @running = false
  end

  def sign_up(listener, method)
    @observers << [listener, method]
  end
end

class HeartBeatListener < Service

    attr_accessor :counter

  required_features :heartbeat

  def start
    @heartbeat.sign_up self, :beat
    @counter = 0
  end

  def beat(loud = false)
    @counter += 1

    puts 'fthump' if loud
  end
end

