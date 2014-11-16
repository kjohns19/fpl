require_relative 'operator.rb'
require_relative 'util.rb'

class Stack
    def initialize
        @stack = []
    end

    def push(val)
        if val.is_a? Operator
            val.execute(self)
        else
            if val.path
                if val.path[0] != '/'
                    val.path = Utils.absolute_path(val.path)
                end
            else
                val.path = Utils.generate_temp_path
            end
            @stack << val
            #puts "Stack: #{@stack.inspect}"
            val.save if val.is_temp?
            #puts File.readlines(val.path).join("")
        end
    end

    def pop(do_load = true)
        var = @stack.pop
        if var
            var.load if do_load
            if var.is_temp?
                if var.type.is_a? FPLObject
                    var.value = var.value.map do |v|
                        val = Variable.new(v)
                        val.load
                        next val
                    end
                end
                var.delete
            end
        else
            puts "Popping from empty stack"
        end
        return var
    end

    def empty?
        @stack.empty?
    end

    def peek
        @stack.last
    end
end
