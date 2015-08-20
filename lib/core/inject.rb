
module Injectable

    def inject(resolver = nil)
        lambda do |*args|
            self.call(*args)
        end
    end
end
