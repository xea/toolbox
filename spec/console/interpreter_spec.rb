require 'console/interpreter'

RSpec.describe Interpreter do

    class IntTestMode < BaseMode

        attr_reader :calls

        mode_id :test

        tables({
            array_lookup: [ "apple", "pear", "strawberry" ],
            hash_lookup: { red: '#f00', green: '#0f0', blue: '#00f' },
            lambda_lookup: -> { [ "dynamic" ] },
            lambda_hash_lookup: -> { { apple: "red", grape: "blue", banana: "yellow" } }
        })

        register_command(:test_cmd, "test", "help")
        register_command(:test_param, "param :a", "help")
        register_command(:test_inline, "inline", "help") { @calls << [ :test_inline ]; :test_inline_success }
        register_command(:test_iparam, "iparam :a", "help") { |a| @calls << [ :test_iparam, a ]; :test_iparam_success }

        def construct
            @calls = []
        end

        def test_cmd
            @calls << [ :test_cmd ]
            :test_cmd_success
        end

        def test_param(a)
            @calls << [ :test_param, a ]
            :test_param_success
        end

    end

    before :example do
        @intp = Interpreter.new true
        @intp.register_mode IntTestMode, :local
        @intp.modes.enter_mode :test
    end

    context "#initialize" do
        it "should initialise with an empty mode registry" do
            expect(@intp.modes).to_not be_nil
        end
    end

    context "#sanitize_input" do
        it 'should leave sanitised inputs as they are' do
            expect(@intp.sanitize_input "a").to eq(["a", :basic])
        end

        it 'should remove leading and trailing whitespaces' do
            expect(@intp.sanitize_input '  spaces   ').to eq(['spaces', :basic])
            expect(@intp.sanitize_input "\ttab\t").to eq(['tab', :basic])
        end

        it 'should leave quoted parts as they are' do
            expect(@intp.sanitize_input "  \"\tquoted and voted \" ").to eq(["\"\tquoted and voted \"", :basic])
        end
    end

    context "#find_command" do
        it 'should find exactly matching commands' do
            expect(@intp.find_command "test").to_not be_nil
            expect(@intp.find_command "test").to be_a(Command)
            expect(@intp.find_command("test").id).to eq(:test_cmd)
            expect(@intp.find_command('inline')).to_not be_nil
            expect(@intp.find_command("inline")).to be_a(Command)
            expect(@intp.find_command("inline").id).to eq(:test_inline)
        end

    end

    context "#extract_user_args" do

    end

    context "#build_context" do
    end

    context "#lookup_args" do
        it 'should return the same key for array tables when the element is defined' do
            expect(@intp.lookup_args({ ':just_something' => "foo"})).to eq({ just_something: "foo" })
            expect(@intp.lookup_args({ '$array_lookup' => "apple" })).to eq({ array_lookup: "apple" })
            expect(@intp.lookup_args({ '$array_lookup' => "pear" })).to eq({ array_lookup: "pear" })
            expect(@intp.lookup_args({ '$array_lookup' => "strawberry" })).to eq({ array_lookup: "strawberry" })
            expect(@intp.lookup_args({ '$hash_lookup' => "red"})).to eq({ hash_lookup: '#f00' })
            expect(@intp.lookup_args({ '$hash_lookup' => "green"})).to eq({ hash_lookup: '#0f0' })
            expect(@intp.lookup_args({ '$hash_lookup' => "blue"})).to eq({ hash_lookup: '#00f' })
            expect(@intp.lookup_args({ '$lambda_lookup' => "dynamic"})).to eq({ lambda_lookup: 'dynamic' })
            expect(@intp.lookup_args({ '$lambda_hash_lookup' => "apple"})).to eq({ lambda_hash_lookup: 'red' })
        end
    end

    context "#table_lookup" do
    end

    context "#attribute_lookup" do
    end

    context "#resolve_arg" do
    end

    context "#process" do
        it "should execute trivial commands" do
            expect(@intp.process "test").to eq(:test_cmd_success)
            expect(@intp.modes.current_mode.calls.pop).to eq([ :test_cmd ])
            expect(@intp.process "param 13").to eq(:test_param_success)
            expect(@intp.modes.current_mode.calls.pop).to eq([ :test_param, '13' ])
            expect(@intp.process "inline").to eq(:test_inline_success)
            expect(@intp.modes.current_mode.calls.pop).to eq([ :test_inline ])
            expect(@intp.process "iparam 16").to eq(:test_iparam_success)
            expect(@intp.modes.current_mode.calls.pop).to eq([ :test_iparam, '16' ])
        end

    end
end
