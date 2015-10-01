require 'service/heartbeat'

RSpec.describe HeartBeatService do

    before :example do
        @beatserv = HeartBeatService.new
        @beatlist = HeartBeatListener.new
    end

    context "#start" do
        it "should generate signals" do
            @beatserv.init
            @beatlist.feature_up :heartbeat, @beatserv
            @beatlist.start
            @beatserv.start 5, 0.1
            @beatserv.stop
            expect(@beatlist.counter).to eq(5)
        end
    end
end
