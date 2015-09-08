require_relative '../core/service'

class HeartBeatService < Service

  provided_features :heartbeat

  def init
    @observers = []
  end

  def start
    @running = true

    while @running do
      @observers.each do |observer|
        observer[0].send observer[1]
      end

      sleep 5
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

  required_features :heartbeat

  def start
    @heartbeat.sign_up self, :beat
  end

  def beat
    puts 'fthump'
  end
end

