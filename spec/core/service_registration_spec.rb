require "core/service_registration"

RSpec.describe ServiceRegistration do

    context "#[]" do
        it "should return it's respective properties" do
            reg = ServiceRegistration.new :srv_id, nil, [ :feature1, :feature2 ], { opt1: true, opt2: false }

            expect(reg[:features].class).to eq(Array)
            expect(reg[:options].class).to eq(Hash)
            expect(reg[:id].class).to eq(Symbol)
        end
    end
end
