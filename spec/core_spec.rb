require "core"

RSpec.describe Core do

    class TestService < Service

        def start
        end
    end

    before(:example) do
        @core = Core.new :testing
    end

    context "#start" do
        it "should set the container state to started" do
            expect(@core.state).to eq(RunState::STOPPED)
            @core.start
            expect(@core.state).to eq(RunState::STARTED)
        end

        it "should start registered services" do
            service = TestService.new
            expect(service.state).to eq(RunState::UNDEFINED)
            @core.register_service :test_service, service, [ :test_feature ]
            @core.start
            expect(service.state).to eq(RunState::STARTED)
        end
    end

    context "#stop" do
        it "should set the container state to stopped" do
            service = TestService.new
            @core.register_service :test_service, service, [ :test_feature ]
            @core.start
            @core.stop
            expect(@core.state).to eq(RunState::STOPPED)
        end

        it "should stop registered services" do
            service = TestService.new
            @core.register_service :test_service, service, [ :test_feature ]
            @core.start
            @core.stop
            expect(service.state).to eq(RunState::STOPPED)
        end
    end
end
