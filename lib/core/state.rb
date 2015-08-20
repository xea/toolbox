module RunState

    UNDEFINED = -1
    STOPPED = 0
    STARTING = 1
    STARTED = 2
    STOPPING = 3

    def set_state_stopped
        @_state = RunState::STOPPED
    end

    def set_state_stopping
        @_state = RunState::STOPPING
    end

    def set_state_started
        @_state = RunState::STARTED
    end

    def set_state_starting
        @_state = RunState::STARTING
    end

    # Query the current state
    def state
        @_state || RunState::UNDEFINED
    end

    # Check if current state equals to the pargument
    def state?(state)
        @_state == state
    end
end
