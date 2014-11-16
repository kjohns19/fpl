require_relative 'operator.rb'
require_relative 'util.rb'

class Stack
    def initialize
        @stack = []
        puts "stck init"
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
            puts @stack
            val.save
            puts File.readlines(val.path).join("")
        end
    end

    def pop
        var = @stack.pop
        var.delete if var.is_temp?
        return var
    end

    def peek
        @stack.last
    end
end
