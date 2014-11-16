require 'operator.rb'
require 'util.rb'

class Stack
	def initilize
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
