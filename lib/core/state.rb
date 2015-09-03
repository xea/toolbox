module RunState

    INSTALLED = :installed
    RESOLVED = :resolved
    STARTING = :starting
    ACTIVE = :active
    STOPPING = :stopping

    def set_state_installed
        @_state = RunState::INSTALLED
    end

    def set_state_resolved
        @_state = RunState::RESOLVED
    end

    def set_state_stopping
        @_state = RunState::STOPPING
    end

    def set_state_active
        @_state = RunState::ACTIVE
    end

    def set_state_starting
        @_state = RunState::STARTING
    end

    # Query the current state
    def state
        @_state || RunState::INSTALLED
    end

    # Check if current state equals to the pargument
    def state?(state)
        @_state == state
    end
end
