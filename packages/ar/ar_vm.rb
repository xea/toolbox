
class ARQLVM

    def initialize(ns = nil)
        @ns = ns
        @stack = []
        @current_model = nil
    end

    def select_model(model_name)
        @stack << @ns.lookup(model_name)[:class_name]
    end

    def filter(&filter_expr)
        top_elem = @stack.pop

        if top_elem.nil?
            raise "Can not apply filter to an empty stack"
        elsif top_elem.is_a? Enumerable
            @stack << top_elem.find_all(&filter_expr)
        #elsif top_elem.is_a? Class and top_elem.ancestors.member? ActiveRecordBaseProxy
            #@stack << top_elem.all.find_all(&filter_expr)
        else
            raise "Can not apply filter to #{top_elem.class}"
        end
    end

    def push(*elem)
        @stack.push *elem
    end

    def pop(n = nil)
        if n.nil?
            @stack.pop
        else
            @stack.pop(n)
        end
    end

    def dup
        push @stack.last unless @stack.last.nil?
    end

    def apply(&function)
        n = function.arity
        items = pop(n)
        push(function.call(*items))
    end

    def empty?
        @stack.empty?
    end

    def dump_stack!
        puts "Stack size: #{@stack.length}"
        @stack.each { |item| puts "  #{item.class} @ #{item.to_s[0..64]}" }
    end
end
