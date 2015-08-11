require "core/service"

RSpec.describe ServiceRegistry do

    class TestRegistry
        include ServiceRegistry
    end

    class TestService < Service
    end
        

    before(:example) do
        @registry = TestRegistry.new
        @service = TestService.new
    end

    context "register_service" do
        it "should register a valid service" do
            @registry.register_service :serv1, @service
            expect(@registry.service :serv1).to_not be_nil
            expect(@registry.service(:serv1).object_id).to eq(@service.object_id)
        end

        it "should not register an id twice without unregistering first" do
            @registry.register_service :serv1, @service
            fake = TestService.new
            expect { @registry.register_service :serv1, fake }.to raise_error "Service with id serv1 has been registered"
        end

        it "should not prevent registering an unregistered id" do
            @registry.register_service :serv1, @service
            @registry.unregister_service :serv1
            expect(@registry.service(:serv1)).to be_nil
            fake = TestService.new
            @registry.register_service :serv1, fake
            expect(@registry.service(:serv1).object_id).to eq(fake.object_id)
        end
    end
end
