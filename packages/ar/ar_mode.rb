require 'console/mode'
require 'console/table'

class ActiveRecordMode < BaseMode

    mode_id :activerecord
    access_from :home, "ar", "Enter ActiveRecord browser"

    register_command(:exit_mode, "exit", "Exit ActiveRecord browser") { |intp| intp.modes.exit_mode }
    register_command(:show_ns, "show namespaces", "Show registered namespaces") { |intp, ar, out|
        pt = PrinTable.new

        entries = ar.namespaces.map do |key, namespace|
            namespace.registered_models.map do |model|
                [ key ]
            end
        end

        out.puts pt.print([ "NAMESPACE", "MODEL" ], entries)
        out.puts "#{entries.length} entries"
    }
end
