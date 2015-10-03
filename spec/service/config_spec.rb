require 'service/config'

RSpec.describe ConfigService do

    TEST_CONFIG_PATH = "_test.yaml"

    before :example do
        @config = ConfigService.new TEST_CONFIG_PATH
    end

    after :all do
        File.delete TEST_CONFIG_PATH
    end

    context '#spawn_new' do
        it "should return a subentry for each spawn_id" do
        end
    end

    context '#set' do
        it "should insert a new entry into the spawned instance" do
            sp = @config.spawn_new :test
            sp['key1'] = 13
            sp['key2'] = "alma"
            sp['key3'] = :korte
            expect(sp['key1']).to eq(13)
            expect(sp['key2']).to eq("alma")
            expect(sp['key3']).to eq(:korte)

            sp = @config.spawn_new :test
            expect(sp['key3']).to eq(:korte)
        end
    end
end
