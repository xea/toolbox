require "core/service"
require "core/dispatcher"

RSpec.describe ServiceRegistration do

    context "#consume" do

        class TestService < Service
            def testmethod(*args)
                args
            end
        end

        class TestDispatcher
            include Dispatcher

            def dispatch(request)
                request
            end
        end

        before(:example) do
            @dispatcher = TestDispatcher.new
            @service = TestService.new
        end

        it "should return a ServiceRegistration for every non-nil object" do
            expect(ServiceRegistration.consume(TestService.new, TestDispatcher.new)).to be_a(ServiceRegistration)
        end

        it "should raise an error when consuming nil" do
            expect { ServiceRegistration.consume(nil, nil) }.to raise_error "Registering nil service is not allowed"
            expect { ServiceRegistration.consume(TestService.new, nil) }.to raise_error "Registering nil dispatcher is not allowed"
        end

        it "should replace service methods with request methods" do
            reg = ServiceRegistration.consume(@service, @dispatcher)
            expect(reg.respond_to? :testmethod).to eq(true)
            expect(reg.testmethod).to be_a(ServiceRequest)
            expect(reg.testmethod.method).to eq(:testmethod)
            expect(reg.testmethod.dispatcher).to eq(@dispatcher)
            expect(reg.testmethod.args).to eq([])
        end

        it "should generate service methods that forward arguments" do
            reg = ServiceRegistration.consume(@service, @dispatcher)
            expect(reg.testmethod.args).to eq([])
            expect(reg.testmethod(1).args).to eq([1])
            expect(reg.testmethod(1, "alma").args).to eq([1, "alma"])
        end

    end
end
