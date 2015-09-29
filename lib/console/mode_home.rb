require_relative 'mode'

class ModeHome < ModeGlobal

    mode_id :home

    tables({
        objecttype: {
            account: "Account"
        }
    })

    register_command(:mode_browse, "browse $objecttype :objectid", "Browse objects") do |objecttype, objectid|
        p objecttype
        p objectid
    end

    register_command(:set_global_var, "set :varname :value") { |varname, value| @global_vars[varname] = value }
    register_command(:get_global_var, "get :varname") { |varname| puts @global_vars[varname] }

    def construct
        @global_vars = {}
    end

end

