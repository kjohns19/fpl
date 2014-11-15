require 'operator.rb'

class Stack
	def initilize
		@stack = []
	end

	def push(val)
		if val.is_a? Operator
			val.execute(self)
		else
			@stack << val
		end
	end

	def pop
		@stack.pop
	end

	def peek
		@stack.last
	end
end
