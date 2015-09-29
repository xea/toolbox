require_relative 'mode'

class ModeCore < BaseMode

    mode_id :core

    register_command(:list_features, "features", "List features")
    register_command(:list_services, "services", "List services")
    register_command(:direct_shutdown, "shutdown", "Initiate direct shutdown")

    def list_features(framework)
        framework.find_services.map { |descriptor| descriptor.features - [ :service ] }.each { |feature| p feature }
    end

    def list_services(framework)
        framework.find_services.each { |descriptor| puts "#{descriptor.service.service_id} #{descriptor.service.state}" }
    end

    def direct_shutdown(framework, reason = nil)
        framework.shutdown
    end
end
