require 'console/autocomplete'
require 'console/mode'

RSpec.describe Autocomplete do

    class TestInterpreter

        def modes
            self
        end

        def current_mode
            TestLocalMode.new
        end

        def global_mode
            TestGlobalMode.new
        end

        def build_context
            {}
        end
    end

    class TestLocalMode < BaseMode
        mode_id :test

        register_command(:inline_command, "inline", "help") {}
        register_command(:include_command, "include", "help") {}
        register_command(:incline_command, "incline", "help") {}
    end

    class TestGlobalMode < BaseMode
        mode_id :test_global

        register_command(:global_command, "global", "help")

        def global_command
        end
    end

    before :example do
        @interpreter = TestInterpreter.new
        @autocomplete = Autocomplete.new @interpreter
    end

    context "#complete" do
        it "should return every command for an empty input" do
            # expected value: { complete: "inline", status: nil, size: 2 }
            expect(@autocomplete.complete "", 0).to be_a(Hash) 
            expect(@autocomplete.complete("", 0)[:complete]).to eq("inline")
            expect(@autocomplete.complete("", 0)[:size]).to eq(4)
        end

        it "should complete for commands matching at least partially" do
            expect(@autocomplete.complete("inl", 3)).to eq({ complete: "ine", status: nil, size: 1 })
        end

        it "should not complete when input is not matching at all" do
            expect(@autocomplete.complete("foobar", 6)).to eq({ complete: nil, status: nil, size: 0 })
        end

        it "should complete with multiple possibilities" do
            result = @autocomplete.complete("in", 2)
            expect(result[:complete]).to eq("line")
            expect(result[:size]).to eq(3)
        end
    end

    context "#find_possible_commands" do
        it "" do
            mode = TestLocalMode.new

            expect(@autocomplete.find_possible_commands "inline", mode, 6).to eq([{:text=>"inline", :complete=>""}])
        end
    end

    context "#reset" do
    end

    context "#next" do
        it "should step" do
            @autocomplete.complete("in", 2)
            result = @autocomplete.next
            expect(result[:complete]).to eq("clude")
            expect(result[:size]).to eq(3)
            result = @autocomplete.next
            expect(result[:complete]).to eq("cline")
            expect(result[:size]).to eq(3)
            result = @autocomplete.next
            expect(result[:complete]).to eq("line")
            expect(result[:size]).to eq(3)
            result = @autocomplete.next
            expect(result[:complete]).to eq("clude")
            expect(result[:size]).to eq(3)
        end
    end

    context "#prev" do
        it "should step" do
            @autocomplete.complete("in", 2)
            result = @autocomplete.prev
            expect(result[:complete]).to eq("cline")
            expect(result[:size]).to eq(3)
            result = @autocomplete.prev
            expect(result[:complete]).to eq("clude")
            expect(result[:size]).to eq(3)
            result = @autocomplete.prev
            expect(result[:complete]).to eq("line")
            expect(result[:size]).to eq(3)
            result = @autocomplete.prev
            expect(result[:complete]).to eq("cline")
            expect(result[:size]).to eq(3)
        end
    end

    context "#reset" do
        it "should reset the internal state, pointing to the first element" do
            @autocomplete.complete("in", 2)
            @autocomplete.next
            @autocomplete.reset
            result = @autocomplete.next
            expect(result[:complete]).to eq("clude")
            expect(result[:size]).to eq(3)
        end
    end

end
