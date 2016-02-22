require 'core/service_registry'
require 'core/service'

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

        it "should accept single items and arrays as features" do
            @registry.register_service :srv1, TestService.new, :testservice1
            expect(@registry.find :testservice1).to_not be_nil
            expect(@registry.find(:testservice1).features).to be_a(Array)

            @registry.register_service :srv2, TestService.new, :testservice2
            expect(@registry.find :testservice2).to_not be_nil
            expect(@registry.find(:testservice2).features).to be_a(Array)
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
            expect(@registry.find(:testfeature).class).to eq(ServiceRegistration)
            expect(@registry.find(:testfeature).service.object_id).to eq(@service.object_id)

            expect(@registry.find { |s| s.class_invariant == 13 }.service.object_id).to eq(@service.object_id)
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

    context "#find_all" do
        it "should return all matching services" do
            @registry.register_service :testservice, TestService.new, [ :test ]
            expect(@registry.find_all :test).to_not be_nil
            expect(@registry.find_all :test).to be_a(Array)
            expect(@registry.find_all(:test).length).to eq(1)
            expect(@registry.find_all(:test)[0].class).to eq(ServiceRegistration)
            expect(@registry.find_all(:test)[0].service.service_id).to eq(:testservice)

            @registry.register_service :othertest, TestService.new, [ :test ]
            expect(@registry.find_all :test).to_not be_nil
            expect(@registry.find_all :test).to be_a(Array)
            expect(@registry.find_all(:test).length).to eq(2)
        end

        it "should return services ordered by priority" do
            @registry.register_service :srv1, TestService.new, [ :test ], { priority: 3 }
            @registry.register_service :srv2, TestService.new, [ :test ], { priority: 5 }
            @registry.register_service :srv3, TestService.new, [ :test ], { priority: 1 }
            @registry.register_service :srv4, TestService.new, [ :test ], { priority: 2 }

            services = @registry.find_all :test
            expect(services.length).to eq(4)
            expect(services[0].options[:priority]).to eq(1)
            expect(services[1].options[:priority]).to eq(2)
            expect(services[2].options[:priority]).to eq(3)
            expect(services[3].options[:priority]).to eq(5)
        end

        it "should not return uninstalled services" do
            @registry.register_service :srv1, TestService.new, [ :test ], { priority: 3 }
            @registry.register_service :srv2, TestService.new, [ :test ], { priority: 5 }
            @registry.register_service :srv3, TestService.new, [ :test ], { priority: 1 }
            @registry.register_service :srv4, TestService.new, [ :test ], { priority: 2 }

            @registry.find(:test).service.set_state_uninstalled
            expect(@registry.find_all(:test).length).to eq(3)
        end
    end

end
