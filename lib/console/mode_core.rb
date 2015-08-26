require_relative 'mode'

class ModeCore < BaseMode

    mode_id :core

    register_command(:list_features, "features", "List features")
    register_command(:list_services, "services", "List services")

    def list_features(framework)
        framework.find_all.map { |descriptor| descriptor.features - [ :service ] }.each { |feature| p feature }
    end

    def list_services(framework)
        framework.find_all.each { |descriptor| puts "#{descriptor.service.service_id} #{descriptor.service.state}" }
    end
end