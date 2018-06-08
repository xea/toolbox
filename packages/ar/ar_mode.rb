require 'console/mode'
require 'console/table'
require 'ast'

include AST::Sexp

class ActiveRecordMode < BaseMode
    mode_id :activerecord
    access_from :home, "ar :namespace_id?", "Enter ActiveRecord browser"

    tables({
        sample_vars: -> { [ "dynamic" ] },
    }) 

    register_command(:exit_mode, "exit", "Exit ActiveRecord browser") { |intp| intp.modes.exit_mode }
    register_command(:show_namespaces, "ns", "List available namespaces")
    register_command(:use_namespace, "ns :namespace_id", "Use the current namespace")
    register_command(:select_model, "select :model_id", "Select and list a model")
    register_command(:show_current_selection, "show", "Show currently selected object(s)")
    register_command(:show_models, "show models", "List available instances of the selected model")
    register_command(:show_stack, "show stack", "Show current scope stack")
    register_command(:pop_stack, "pop :amount?", "Pop the top N elements (default is 1) from the stack")

    # When entering AR browse mode, let's pre-select the requested namespace, if any
    def post_enter(intp, out, ar, namespace_id, ctx)
        new_ns = use_namespace(out, ar, namespace_id) unless namespace_id.nil?

        if new_ns == false
            intp.modes.exit_mode
        else
            @ns = new_ns
            @scope_stack = []
        end

    end

    def use_namespace(out, ar, namespace_id)
        new_ns = ar.namespace(namespace_id.to_s.to_sym)

        if new_ns
            @ns = new_ns
            out.puts "Currently used namespace: #{@ns.id}"
            @ns
        else
            out.puts "Selected namespace '#{namespace_id}' does not exist"
            false
        end

    end

    def show_namespaces(intp, ar, out)
        pt = PrinTable.new

        nss = ar.namespaces.map { |ns| ns.id.to_s }

        out.puts pt.print([ "NAMESPACE" ], [ nss ])
        out.puts "#{nss.length} entries"

        if @ns.nil?
            out.puts "No used namespace"
        else
            out.puts "Currently used namespace: #{@ns.id}" unless @ns.nil?
        end
    end

    # select account                              <- use specific model
    # select account/12                           <- use specific instance of a model
    # select account/12/route                     
    # select account/12/route/@first
    # select account/12/route/#description=14/    <- use filter condition
    # select account/12/route@enabled/            <- use specific view/partition
    #
    # stack item: { type: :model, object: #<12312312>, selector: "" }

    def select_model(intp, ar, out, model_id)
        def select_instance_within_model(instance_id, out, fragments)
            begin
                scope_obj = @scope_stack.last[:object][:class_name].find(instance_id)

                @scope_stack << { type: :instance, object: scope_obj, selector: instance_id.to_s }

                if fragments.length > 0
                    lookup_model(fragments, out)
                else
                    out.puts "Instance '#{instance_id}' selected"
                    scope_obj
                end
            rescue => e
                out.puts "Instance '#{instance_id}' not found: #{e}"
                false
            end
        end

        def select_instance_within_list(instance_id, out, fragments)
            begin
                scope_obj = @scope_stack.last[:object].find { |obj| obj.id == instance_id.to_i }

                @scope_stack << { type: :instance, object: scope_obj, selector: instance_id.to_s }

                if fragments.length > 0
                    lookup_model(fragments, out)
                else
                    out.puts "Instance '#{instance_id}' selected"
                    scope_obj
                end
            rescue => e
                out.puts "Instance '#{instance_id}' not found: #{e}"
                false
            end
        end

        def select_model_association(assoc_name, out, fragments)
            # model_id is expected to be a model name
            first_model = @ns.registered_models.find { |m| m[:id] == assoc_name.to_sym }

            if first_model.nil? or first_model.empty? 
                out.puts "Selected model was not found"
            else
                @scope_stack << { type: :model, object: first_model, selector: assoc_name }

                if fragments.length > 0
                    lookup_model(fragments, out)
                else
                    out.puts "Model '#{assoc_name}' selected"
                    @scope_stack.last
                end
            end
        end

        def lookup_model(fragments, out)
            current = fragments.shift

            if current[0] >= '0' and current[0] <= '9'
                if @scope_stack.last[:type] == :model
                    select_instance_within_model current.to_i, out, fragments
                else
                    select_instance_within_list current.to_i, out, fragments
                end
            else
                last_parent = @scope_stack.find_all { |e| e[:type] == :instance }.last

                if last_parent.nil?
                    select_model_association current, out, fragments
                else
                    if @scope_stack.last[:type] == :instance
                        # mode_id is expected to be a relation name of the last parent
                        
                        assoc = @scope_stack.last[:object].class.reflect_on_all_associations.find { |ass| ass.name == current.to_sym }

                        if assoc.is_a? ActiveRecord::Reflection::BelongsToReflection
                        elsif assoc.is_a? ActiveRecord::Reflection::HasManyReflection
                        end

                        items = @scope_stack.last[:object].send assoc.name

                        unless assoc.collection?
                            items = [ items ]
                        end

                        @scope_stack << { type: :list, object: items, selector: current }

                        if fragments.length > 0
                            lookup_model(fragments, out)
                        else
                            @scope_stack.last
                        end
                    else
                        out.puts "TODO"
                    end
                end
            end
        end

        if model_id.nil? or model_id.empty?
            out.puts "A selector wasn't specified"
        else
            fragments = model_id.split('/').find_all { |e| !e.empty? }

            if fragments.length > 0 and lookup_model(fragments, out)
                show_current_selection out
            else
                out.puts "A selector wasn't specified"
            end
        end
    end

    def show_current_selection(out)
        if @scope_stack.nil? or @scope_stack.empty?
            out.puts "Nothing has been selected"
        else
            pt = PrinTable.new

            if @scope_stack.last[:type] == :list
                if @scope_stack.length > 1
                    lastobj = @scope_stack.last[:object]
                    test_obj = @scope_stack[-2][:object].class.reflect_on_all_associations.find { |ass| ass.name == @scope_stack.last[:selector].to_sym }.klass.new

                    list_fields = [ :core_fields, :essential_fields, :basic_fields ].map { |fg| test_obj.send fg }.reduce(:+) 

                    out.puts(pt.print list_fields.map { |f| f.to_s.upcase }, lastobj.map { |instance| list_fields.map { |f| instance.send f }})
                end
            elsif @scope_stack.last[:type] == :instance
                pt = PrinTable.new

                out.puts pt.print([ :association, :active ], @scope_stack.last[:object].class.reflect_on_all_associations.map { |assoc| [ assoc.name.to_s, true ] }, :db)
            elsif @scope_stack.last[:type] == :model
                lastobj = @scope_stack.last[:object]

                list_fields = [ :core_fields, :essential_fields, :basic_fields ].map { |fg| lastobj[:class_name].new.send fg }.reduce(:+) 

                out.puts(pt.print list_fields.map { |f| f.to_s.upcase }, lastobj[:class_name].all.map { |instance| list_fields.map { |f| instance.send f }})
            end
        end
    end

    def show_models(intp, ar, out)
        pt = PrinTable.new

        # [ { id: id, class_name: Example } ]
        nss = @ns.nil? ? ar.namespaces : [ @ns ]

        entries = nss.map do |namespace|
            namespace.registered_models.map do |model|
                [ namespace.id, model[:id], model[:class_name].to_s ]
            end
        end

        out.puts pt.print([ "NAMESPACE", "MODEL ID", "CLASS" ], entries.flatten(1))
        out.puts "#{entries.length} entries"
    end

    def show_stack(out)
        if @scope_stack.nil?
            out.puts "Scope stack is currently empty"
        else
            @scope_stack.each_with_index { |scope, idx| out.puts "#{idx}. #{scope}" }
        end
    end

    def pop_stack(out, amount = 1)
        @scope_stack.pop(amount.to_i) unless @scope_stack.empty?
    end
=begin
    register_command(:show_associations, "show associations of $sample_vars", "Show associations of the selected model") { |intp, ar, out, sample_vars|
        puts "#{current_models}"
        model = @ns.lookup(model_id.to_sym)

        if model.nil?
            out.puts "Couldn't find selected model"
        else
            pt = PrinTable.new

            out.puts pt.print([ :association, :active ], model[:class_name].reflect_on_all_associations.map { |assoc| [ assoc.name.to_s, true ] }, :db)
        end

    }

    def dynamic_command(input)
    end

    def process_object(result, out)
        case result.type
        when :select_result
            pt = PrinTable.new

            head = result.children.first[0]
            body = result.children.first[1]

            out.puts pt.print(head, body, :db)
        end
    end

    def list_model(out, ar, model_id, verbosity = nil)
        model = @ns.lookup(model_id.to_sym)

        if model.nil?
            out.puts "Couldn't find selected model"
        else
            pt = PrinTable.new

            model_class = model[:class_name]
            model_example = model_class.new

            object_query = if model_example.order_fields.nil? or model_example.order_fields.empty?
                -> { model_class.all }
            else
                -> { model_class.order(*model_example.order_fields) }
            end

            out.puts pt.print(model[:class_name].new.filter_fields(verbosity), (object_query.call).map { |instance| instance.flatten_fields(verbosity) }, :db)
        end
    end
=end
    def prompt
        if @scope_stack.nil? or @scope_stack.empty?
            "(#{'*'.red})"
        else
            case @scope_stack.last[:type]
            when :instance
                "(#{@scope_stack.last[:object].class.model_name.human.to_s.red}/#{@scope_stack.last[:object].id})"
            when :model
                "(#{@scope_stack.last[:object][:class_name].model_name.human.to_s.red}/*})"
            when :list
                "(#{@scope_stack.last[:selector].to_s.red}/*)"
            end
        end
    end
end

class Object
    def map(&func)
        func.call self
    end
end
