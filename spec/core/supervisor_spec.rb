require 'core/supervisor'

RSpec.describe SupervisorCompanion do

    class SuperVisorTestActor
        include Celluloid

        attr_reader :name, :args, :blk

        def initialize(name, *args, &blk)
            @name = name
            @args = args
            @blk = blk
        end

        def crash
            raise "Crash Test"
        end
    end

    before :example do
        @sv = SupervisorCompanion.new
    end

    context '#supervise' do
        it 'should return the newly created actor' do
            actor = @sv.supervise(:test1, SuperVisorTestActor, "test1")
            expect(actor).to_not be_nil
            expect(@sv[:test1]).to eq(actor)
        end

        it 'should pass all the arguments to the constructor' do
            actor = @sv.supervise(:test2, SuperVisorTestActor, "test2", "arg1", "arg2") { puts "initialise" }
            expect(actor.name).to eq("test2")
        end
    end

    context '#actor_died' do
    end

    context '#[]' do
        it 'should be able to get all the registered actors to the registry' do
            actor3 = @sv.supervise(:test3, SuperVisorTestActor, "test3")
            actor4 = @sv.supervise(:test4, SuperVisorTestActor, "test4")
            actor5 = @sv.supervise(:test5, SuperVisorTestActor, "test5")

            expect(@sv[:test3]).to eq(actor3)
            expect(@sv[:test4]).to eq(actor4)
            expect(@sv[:test5]).to eq(actor5)
        end
    end
end
