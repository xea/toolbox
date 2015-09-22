require 'console/mode'

RSpec.describe BaseMode do
    class EmptyMode < BaseMode
    end

    class IdMode < BaseMode
        mode_id :id_mode
    end

    class TestMode < BaseMode
        mode_id :test

        attr_reader :calls

        def post_enter
            @calls << :post_enter
        end

        def pre_exit
            @calls << :pre_exit
        end

        def construct(*args)
            @calls = []
            @calls << :construct
        end

        register_command(:inline_command, "", "") {}
    end

    context "#initialize" do
        it "should populate all the feature arrays" do
            mode = EmptyMode.new
            expect(mode.mode_id).to_not be_nil
            expect(mode.mode_id).to eq(:EmptyMode)
            expect(mode.commands).to_not be_nil
            expect(mode.commands).to eq({})
            expect(mode.filters).to eq({})
            expect(mode.tables).to eq({})

            mode = IdMode.new
            expect(mode.mode_id).to_not be_nil
            expect(mode.mode_id).to eq(:id_mode)
            expect(mode.commands).to_not be_nil
            expect(mode.commands).to eq({})
            expect(mode.filters).to eq({})
            expect(mode.tables).to eq({})
        end

        it "should call construct if specified" do
            mode = TestMode.new
            expect(mode.calls.member? :construct).to eq(true)
        end

        it "should define construct, post_enter and pre_exit methods" do
            mode = EmptyMode.new
            expect(mode.respond_to? :construct).to eq(true)
            expect(mode.respond_to? :post_enter).to eq(true)
            expect(mode.respond_to? :pre_exit).to eq(true)
        end
    end

    context "#available_commands" do
        it "should list commands by default" do
            mode = TestMode.new
            expect(mode.available_commands).to_not be_nil
            expect(mode.available_commands.length).to eq(1)
            expect(mode.available_commands[0]).to be_a(Command)
        end

    end

    context "#find_command" do
    end
end
