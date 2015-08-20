require "core/service"
require "core/dispatcher"

RSpec.describe Service do
    context "traits" do

        it "should define all traits" do
            class TestService < Service
                traits :test_trait

                test_trait :value
            end

            service = TestService.new
            expect(service.test_trait).to_not be_nil
            expect(service.test_trait).to eq([:value])
        end
    end
end

RSpec.describe ServiceProxy do

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

        it "should return a ServiceProxy for every non-nil object" do
            expect(ServiceProxy.consume(TestService.new, TestDispatcher.new)).to be_a(ServiceProxy)
        end

        it "should raise an error when consuming nil" do
            expect { ServiceProxy.consume(nil, nil) }.to raise_error "Registering nil service is not allowed"
            expect { ServiceProxy.consume(TestService.new, nil) }.to raise_error "Registering nil dispatcher is not allowed"
        end

        it "should replace service methods with request methods" do
            reg = ServiceProxy.consume(@service, @dispatcher)
            expect(reg.respond_to? :testmethod).to eq(true)
            expect(reg.testmethod).to be_a(ServiceRequest)
            expect(reg.testmethod.method).to eq(:testmethod)
            expect(reg.testmethod.dispatcher).to eq(@dispatcher)
            expect(reg.testmethod.args).to eq([])
        end

        it "should generate service methods that forward arguments" do
            reg = ServiceProxy.consume(@service, @dispatcher)
            expect(reg.testmethod.args).to eq([])
            expect(reg.testmethod(1).args).to eq([1])
            expect(reg.testmethod(1, "alma").args).to eq([1, "alma"])
        end

    end
end
