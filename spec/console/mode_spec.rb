require 'console/mode'

RSpec.describe BaseMode do

    class EmptyMode < BaseMode
    end

    class IdMode < BaseMode
        mode_id :id_mode
    end

    class ModeTestMode < BaseMode
        mode_id :test

        attr_reader :calls
        attr_accessor :filter_switch

        def post_enter
            @calls << :post_enter
        end

        def pre_exit
            @calls << :pre_exit
        end

        def construct(*args)
            @calls = []
            @calls << :construct
            @filter_switch = false
        end

        register_command(:inline_command, "inline", "") { @calls << :inline_command }
        register_command(:test_command, "test", "")
        register_command(:invisible_command, "invisible", "", scope(false)) { puts "this command shouldn't appear anywhere" }
        register_command(:filtered_command, "filtered", "", scope(true) { @filter_switch }) { puts "this command is filtered" }

        def test_command
            @calls << :test_command
        end
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
            mode = ModeTestMode.new
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
            mode = ModeTestMode.new
            expect(mode.available_commands).to_not be_nil
            expect(mode.available_commands.length).to eq(3)
            expect(mode.available_commands[0]).to be_a(Command)
        end

        it "considers visibility filters" do
            mode = ModeTestMode.new

            expect(mode.filter_switch).to eq(false)
            original_length = mode.available_commands.length

            mode.filter_switch = true

            expect(mode.available_commands.length).to eq(original_length + 1)

            mode.filter_switch = false

            expect(mode.available_commands.length).to eq(original_length)
        end
    end

    context "#find_command" do
        it "should always return a Method instance" do
            mode = ModeTestMode.new
            expect(mode.find_command "test").to_not be_nil
            expect(mode.find_command("test").method).to be_a(Method)
            expect(mode.find_command 'inline').to_not be_nil
            expect(mode.find_command('inline').method).to be_a(Method)
        end
    end

    context "#register_command" do
        it "should register commands as instance methods" do
            mode = ModeTestMode.new
            expect(mode.respond_to? :test_command).to be_truthy
        end

        it "should register inline commands as instance methods" do
            mode = ModeTestMode.new
            expect(mode.respond_to? :inline_command).to be_truthy
        end
    end

    context "#visible_commands" do
        it "should show only those available commands that are visible too" do
            mode = ModeTestMode.new
            expect(mode.visible_commands).to_not be_nil

            expect(mode.visible_commands.length).to eq(mode.available_commands.length - 1)
        end
    end
end
