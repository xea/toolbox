require 'core/dispatcher'

RSpec.describe Dispatcher do
    class TestDispatcher
        include Dispatcher
    end

    context "#dispatch" do
        it "should pass all the arguments to the dispatched method" do
            
        end
    end
end

RSpec.describe ServiceRequest do
end
