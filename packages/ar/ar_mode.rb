require 'console/mode'
require 'console/table'

class ActiveRecordMode < BaseMode

    mode_id :activerecord
    access_from :home, "ar :namespace_id?", "Enter ActiveRecord browser"

    register_command(:exit_mode, "exit", "Exit ActiveRecord browser") { |intp| intp.modes.exit_mode }
    register_command(:list_model, "list :model_id", "List model instances")
    register_command(:select_namespace, "select :namespace_id", "Select the current namespace")

    register_command(:show_namespaces, "show namespaces", "Show registered namespaces") { |intp, ar, out|
        pt = PrinTable.new

        nss = ar.namespaces.map { |ns| ns.id.to_s }

        out.puts pt.print([ "NAMESPACE" ], [ nss ])
        out.puts "#{nss.length} entries"
    }

    register_command(:show_models, "show models", "Show registered models") { |intp, ar, out|
        pt = PrinTable.new

        # [ { id: id, class_name: Example } ]
        entries = ar.namespaces.map do |namespace|
            namespace.registered_models.map do |key, model|
                [ namespace.id, key, model ]
            end
        end

        out.puts pt.print([ "NAMESPACE", "MODEL ID", "CLASS" ], entries.flatten(1))
        out.puts "#{entries.length} entries"
    }

    def post_enter(out, ar, namespace_id)
        select_namespace out, ar, namespace_id
    end

    def select_namespace(out, ar, namespace_id)
        @ns = ar.namespace(namespace_id)

        out.puts "Currently selected namespace: #{@ns.id}"
    end

    def list_model(out, ar, model_id)
        model = ar.lookup(model_id)

        if model.nil?
            out.puts "Couldn't find selected model"
        else
            pt = PrinTable.new

        end
    end
end
