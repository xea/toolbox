require 'console/mode'
require 'console/table'

require_relative 'ar_vm'

class ActiveRecordVMMode < BaseMode
    mode_id :activerecord_vm

    def post_enter(ns)
        @vm = ARQLVM.new ns
    end

    def lofasz
        "LOFASZ"
    end

    register_command(:apply_function, "apply :functionid", "Apply a function") { |functionid, out|
        out.puts(@vm.apply &method(functionid.to_sym))
    }

    register_command(:dump_stack, "dump", "Dump VM Stack") {
        @vm.dump_stack!
    }

    register_command(:duplicate_top, "dup", "Duplicate top stack element") {
        @vm.dup
    }

    register_command(:filter, "filter", "Filter results") {
        @vm.filter { |item| true }
    }

    register_command(:exit_mode, "exit", "Exit current mode") { |intp|
        intp.modes.exit_mode
    }

    register_command(:show_is_empty, "isempty", "Show whether the VM stack is empty") { |out|
        out.puts("VM Stack is empty: %s" % @vm.empty?)
    }

    register_command(:select_model, "select model :modelid", "Select a model") { |modelid|
        @vm.select_model modelid.to_sym
    }

    register_command(:push_element, "push :element", "Push element onto stack") { |element|
        @vm.push element
    }

    register_command(:pop_element, "pop", "Pop element from stack") { |out|
        out.puts @vm.pop.inspect
    }
end
