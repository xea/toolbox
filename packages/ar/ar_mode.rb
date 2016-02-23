require 'console/mode'
require 'console/table'

class ActiveRecordMode < BaseMode

    mode_id :activerecord
    access_from :home, "ar", "Enter ActiveRecord browser"

    register_command(:exit_mode, "exit", "Exit ActiveRecord browser") { |intp| intp.modes.exit_mode }
    register_command(:show_ns, "show namespaces", "Show registered namespaces") { |intp, ar, out|
        pt = PrinTable.new

        # [ { id: id, class_name: Example } ]
        entries = ar.namespaces.map do |key, namespace|
            namespace.registered_models.map do |model|
                [ key, model[:id], model[:class_name] ]
            end
        end

        out.puts pt.print([ "NAMESPACE", "MODEL ID", "CLASS" ], entries.flatten(1))
        out.puts "#{entries.length} entries"
    }
end
