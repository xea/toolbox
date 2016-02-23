require 'console/mode'

class ActiveRecordMode < BaseMode

    mode_id :activerecord
    access_from :home, "ar", "Enter ActiveRecord browser"
end
