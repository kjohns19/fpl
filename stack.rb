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
                val.path = Utils.absolute_path(val.path)
            else
                val.path = Utils.generate_temp_path
            end
            @stack << val
            #puts "Stack: #{@stack.inspect}"
            val.save
            #puts File.readlines(val.path).join("")
        end
    end

    def pop
        var = @stack.pop
        if var
            var.load
            var.delete if var.is_temp?
        end
        return var
    end

    def peek
        @stack.last
    end
end
