module RunState

    UNINSTALLED = :uninstalled
    INSTALLED = :installed
    RESOLVED = :resolved
    STARTING = :starting
    ACTIVE = :active
    STOPPING = :stopping
    STOPPED = :stopped

    def set_state_uninstalled(verbose_state = "")
        @_state = RunState::UNINSTALLED
        @_verbose_state = verbose_state
    end

    def set_state_installed(verbose_state = "")
        @_state = RunState::INSTALLED
        @_verbose_state = verbose_state
    end

    def set_state_resolved(verbose_state = "")
        @_state = RunState::RESOLVED
        @_verbose_state = verbose_state
    end

    def set_state_stopping(verbose_state = "")
        @_state = RunState::STOPPING
        @_verbose_state = verbose_state
    end

    def set_state_active(verbose_state = "")
        @_state = RunState::ACTIVE
        @_verbose_state = verbose_state
    end

    def set_state_starting(verbose_state = "")
        @_state = RunState::STARTING
        @_verbose_state = verbose_state
    end

    def set_state_stopped(verbose_state = "")
        @_state = RunState::STOPPED
        @_verbose_state = verbose_state
    end

    # Query the current state
    def state
        @_state || RunState::INSTALLED
    end

    def verbose_state
        @_verbose_state
    end

    # Check if current state equals to the pargument
    def state?(state)
        @_state == state
    end
end
