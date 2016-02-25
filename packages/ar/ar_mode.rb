require 'console/mode'
require 'console/table'

class ActiveRecordMode < BaseMode

    mode_id :activerecord
    access_from :home, "ar :namespace_id?", "Enter ActiveRecord browser"

    register_command(:exit_mode, "exit", "Exit ActiveRecord browser") { |intp| intp.modes.exit_mode }
    register_command(:select_ns, "select :namespace_id", "Select the current namespace") { |ar, namespace_id| @ns = ar.namespace(namespace_id) }
    register_command(:show_ns, "show namespaces", "Show registered namespaces") { |intp, ar, out|
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

    def post_enter(ar, namespace_id)
        @ns = ar.namespace(namespace_id)

        p @ns
    end
end
