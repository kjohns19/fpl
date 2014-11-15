require 'operator.rb'

class BinaryOp
    def initialize(op)
        @op = op
    end

    def execute(stack)
        val2 = stack.pop
        val1 = stack.pop
        result = val1.send(@op, val2)
        stack.push(result)
    end
end

class UnaryOp
    def initialize(op)
        @op = op
    end

    def execute(stack)
        val = stack.pop
        result = val.send(@op)
        stack.push(result)
    end
end
