require 'service/discovery'

RSpec.describe DiscoveryService do

    context "#init" do
        it "should initialise an empty package db" do
            srv = DiscoveryService.new
            srv.init

            
        end
    end
end
