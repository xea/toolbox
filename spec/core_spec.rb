require 'core'

RSpec.describe Core do

    class TestService < Service
        provided_features :test
    end

    before(:context) do
        @pure_core = Core.new "pure_test", true
        @core = Core.new "test", false
        @core.define_singleton_method(:current_stage) { @current_stage }
        @pure_core.define_singleton_method(:current_stage) { @current_stage }
        @test_service = TestService.new
    end

    context "#initialize" do
        
        it "should normally initialise with the essential services" do
            expect(@core.framework).to_not be_nil
            expect(@core.service_registry).to_not be_nil
            expect(@core.event_queue).to_not be_nil
            expect(@core.system_name).to_not be_nil
        end

        it "should assign a framework name properly" do
            expect(@core.system_name).to eq("test")
        end

        it "should initialise properly when started in pure mode" do
            expect(@pure_core.system_name).to eq("pure_test")
            expect(@pure_core.event_queue).to_not be_nil
            expect(@pure_core.service_registry).to_not be_nil
        end

        it "should not initialise services when started in pure mode" do
            expect(@pure_core.framework).to be_nil
            expect(@pure_core.service_registry.service(:console_host)).to be_nil
        end
    end

    context "#register_service" do

        it "should add new registrations to the queue" do
            expect(@pure_core.current_stage).to eq([])

            @pure_core.register_service :test_service, @test_service
            expect(@pure_core.current_stage.length).to eq(1)
            expect(@pure_core.current_stage[0]).to be_a(Array)
            expect(@pure_core.current_stage[0][0]).to eq(:test_service)
            expect(@pure_core.current_stage[0][1]).to eq(@test_service)
            expect(@pure_core.current_stage[0][2]).to eq(nil)
        end

        it "should return the id of the newly registered service" do
            result = @pure_core.register_service :test_service, @test_service
            expect(result).to eq(:test_service)
        end
    end

    context "#commit_stage" do
    end

    context "#shutdown" do
        it "should drop a shutdown message into the event queue" do
            @core.shutdown
            expect(@core.event_queue.size).to eq(1)
            expect(@core.event_queue.pop).to eq(:shutdown)
        end
    end
end
