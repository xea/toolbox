require_relative 'mode'
require_relative 'table'

class ModeCore < BaseMode

    mode_id :core

    register_command(:list_features, "features", "List features")
    register_command(:list_services, "services", "List services")
    register_command(:start_service, "start :service_id", "Start service")
    register_command(:stop_service, "stop :service_id", "Stop service")
    register_command(:direct_shutdown, "shutdown", "Initiate direct shutdown")
    register_command(:exit_mode, "exit", "Exit current mode") { |intp| intp.modes.exit_mode }

    def construct
        @table = PrinTable.new
    end

    def list_features(out, framework)
        out.puts @table.print([ "ID", "PROVIDED", "REQUIRED", "OPTIONAL" ], framework.find_services.map { |descriptor| 
            [ descriptor.service.service_id, 
              (descriptor.features - [:service]).join(","), 
              descriptor.service.required_features.join(','), 
              descriptor.service.optional_features.join(',') 
            ] 
        })
    end

    def list_services(out, framework)
        out.puts @table.print([ "ID", "STATE", "OID", "CLASS" ], framework.find_services.map { |descriptor| 
            [ descriptor.service.service_id, 
              descriptor.service.state, 
              "0x%12x" % descriptor.service.object_id, 
              descriptor.service.class.name 
            ] 
        })
    end

    def stop_service(out, framework, service_id)
        framework.stop_service service_id
    end

    def start_service(out, framework, service_id)
        framework.start_service service_id
    end

    def direct_shutdown(framework, reason = nil)
        framework.shutdown
    end
end
