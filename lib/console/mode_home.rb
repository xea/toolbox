require_relative 'mode'

class ModeHome < ModeGlobal

    mode_id :home

    tables({
        objecttype: {
            account: "Account"
        }
    })

end
