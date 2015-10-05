require 'core'

RSpec.describe Core do

    class TestService < Service
        provided_features :test
    end

    class ProducerService < Service
        provided_features :provider

        attr_reader :running

        def initialize
            super
            @running = false
        end

        def start
            @running = true
        end

        def stop
            @running = false
        end
    end

    class ConsumerService < Service
        required_features :provider

        def provider
            @provider
        end
    end

    class OptionalConsumerService < Service
        optional_features :provider

        def provider
            @provider
        end
    end

    before(:example) do
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
            expect(@pure_core.current_stage[0][2]).to eq([:test])
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

    context "#process_service_queue" do
        it "should not do anything when stages are empty" do
            expect{@pure_core.process_service_queue}.to_not raise_error
        end

        it "should start immediate independent services" do
            service_a = ProducerService.new
            service_b = ProducerService.new
            service_c = ProducerService.new
            @pure_core.register_service :producer_a, service_a
            @pure_core.register_service :producer_b, service_b
            @pure_core.register_service :producer_c, service_c
            @pure_core.commit_stage
            @pure_core.process_service_queue

            expect(service_a.state).to eq(:active)
            expect(service_b.state).to eq(:active)
            expect(service_c.state).to eq(:active)
        end

        it "should start immediate dependencies" do
            producer = ProducerService.new
            consumer = ConsumerService.new
            @pure_core.register_service :producer, producer
            @pure_core.register_service :consumer, consumer
            @pure_core.commit_stage
            @pure_core.process_service_queue

            expect(producer.state).to eq(:active)
            expect(consumer.state).to eq(:active)
        end
    end

end
