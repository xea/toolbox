require "core/service_registry"

RSpec.describe ServiceRegistry do

    class TestRegistry
        include ServiceRegistry
    end

    class TestService < Service

        def class_invariant
            13
        end
    end
        

    before(:example) do
        @registry = TestRegistry.new
        @service = TestService.new
    end

    context "#register_service" do
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

        it "should register the services' features" do
            @registry.register_service :serv1, @service, [ :testservice ]
        end
    end

    context "#unregister_service" do
        it "should remove existing registrations" do
            @registry.register_service :serv1, @service, [ :testservice ]
            expect(@registry.find :testservice).to_not be_nil
            @registry.unregister_service :serv1
            expect(@registry.find :testservice).to be_nil
        end
    end

    context "#find" do
        it "should find services by id" do
            @registry.register_service :serv1, @service
            expect(@registry.find { |service| service.service_id == :serv1 })
        end

        it "should find services by feature specification" do
            @registry.register_service :serv1, @service, [ :testfeature ]
            expect(@registry.find(:testfeature).object_id).to eq(@service.object_id)

            expect(@registry.find { |s| s.class_invariant == 13 }.object_id).to eq(@service.object_id)
        end

        it "should return nil when passing no specification" do
            @registry.register_service :serv1, @service, [ :testfeature ]
            expect(@registry.find(nil)).to be_nil
        end

        it "shouldn't return a service for invalid features" do
            @registry.register_service :serv1, @service, [ :testfeature ]
            expect(@registry.find(:doesntexist)).to be_nil
        end
    end
end
