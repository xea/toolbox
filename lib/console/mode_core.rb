require_relative 'mode'
require_relative 'table'

class ModeCore < BaseMode

    mode_id :core

    register_command(:list_features, "features", "List features")
    register_command(:list_services, "services", "List services")
    register_command(:direct_shutdown, "shutdown", "Initiate direct shutdown")

    def construct
        @table = PrinTable.new
    end

    def list_features(out, framework)
        out.puts @table.print([ "ID", "Features" ], framework.find_services.map { |descriptor| [ descriptor.service.service_id, (descriptor.features - [:service]).join(",") ] })
    end

    def list_services(out, framework)
        out.puts @table.print([ "ID", "State" ], framework.find_services.map { |descriptor| [ descriptor.service.service_id, descriptor.service.state ] } )
    end

    def direct_shutdown(framework, reason = nil)
        framework.shutdown
    end
end
