require_relative 'mode'

class ModeCore < BaseMode

    mode_id :core

    register_command(:list_features, "features", "List features")

    def list_features(framework)
        p framework
        puts "blabla"
    end
end
