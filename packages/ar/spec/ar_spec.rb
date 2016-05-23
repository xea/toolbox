require 'core/service'
require 'ar/ar'

RSpec.describe ActiveRecordService do

    class TestNamespace

        attr_reader :unique_id

        include ActiveRecordNameSpace

        def initialize(unique_id = nil)
            @unique_id = unique_id
        end

        def lookup(model_id)
        end
    end

    module ActiveRecordServiceSpec
        class ConsoleService
            attr_reader :helpers, :modes

            def initialize
                @helpers = {}
                @modes = []
            end

            def register_helper(id, helper)
                @helpers[id] = helper
            end

            def register_mode(mode_class)
                @modes << mode_class
            end

            def unregister_mode(mode_class)
                @modes.delete mode_class
            end

            def unregister_helper(id)
                @helpers.delete id
            end
        end
    end

    context "#start" do
        it "should initialise the service without namespaces" do
            ar = ActiveRecordService.new
            ar.start

            expect(ar.namespaces).to eq([])
        end
    end

    context "#stop" do
        it "should clear the registered namepsaces table" do
            ar = ActiveRecordService.new
            ar.start

            ar.register_namespace :test1, TestNamespace.new
            ar.register_namespace :test2, TestNamespace.new
            ar.register_namespace :test3, TestNamespace.new

            ar.stop
            expect(ar.namespaces.length).to eq(0)
        end
    end

    context "#register_namespace" do
        it "should add the new namespace under it's key" do
            ar = ActiveRecordService.new
            ar.start

            ar.register_namespace :test, TestNamespace.new
            expect(ar.namespaces.length).to eq(1)
            expect(ar.namespaces[0].id).to eq(:test)
        end
    end

    context "#unregister_namespace" do
        it "should remove existing registered namespaces" do
            ar = ActiveRecordService.new
            ar.start

            ar.register_namespace :test, TestNamespace.new
            expect(ar.namespaces.length).to eq(1)

            ar.unregister_namespace :test
            expect(ar.namespaces.length).to eq(0)
        end
    end

    context "#namespace" do
        it "should return the namespace referred by id" do
            ar = ActiveRecordService.new
            ar.start

            ar.register_namespace :test1, TestNamespace.new(1)
            ar.register_namespace :test2, TestNamespace.new(2)

            expect(ar.namespace(:test1).id).to eq(:test1)
            expect(ar.namespace(:test2).id).to eq(:test2)
        end
    end

    context "#feature_console_up" do
        it "should register itself cleanly" do
            ar = ActiveRecordService.new
            ar.start

            console = ActiveRecordServiceSpec::ConsoleService.new
            ar.feature_console_up console

            expect(console.helpers.keys.member? :ar).to eq(true)
            expect(console.modes.member? ActiveRecordMode).to eq(true)
        end
    end

    context "#feature_console_down" do
        it "should unregister itself cleanly" do
            ar = ActiveRecordService.new
            ar.start

            console = ActiveRecordServiceSpec::ConsoleService.new
            ar.feature_console_up console
            ar.feature_console_down console

            expect(console.helpers.keys.member? :ar).to eq(false)
            expect(console.modes.member? ActiveRecordMode).to eq(false)
        end
    end

    context "#lookup" do

        it "should allow accessing registered models" do

            ar = ActiveRecordService.new



        end
    end
end

RSpec.describe ActiveRecordNameSpaceProxy do
end
