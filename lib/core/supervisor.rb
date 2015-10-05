require 'celluloid/current'

class SupervisorCompanion

    include Celluloid

    trap_exit :actor_died

    def initialize(core = nil)
        @core = core
        # Not sure if this is really needed
        @supervisors = []
    end

    def supervise(service_id, service_class, *args, &blk)
        sv = service_class.supervise(as: service_id, args: args)
        @supervisors << sv unless @supervisors.member? sv
        sv.actors.last
    end

    def actor_died(actor, error)
        puts "An actor has died #{actor} #{error}"
    end

    def [](actor_name)
        Celluloid::Actor[actor_name.to_sym]
    end
end
