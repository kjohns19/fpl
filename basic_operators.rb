require 'operator.rb'

class BinaryOp < Operator
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

class UnaryOp < Operator
    def initialize(op)
        @op = op
    end

    def execute(stack)
        val = stack.pop
        result = val.send(@op)
        stack.push(result)
    end
end

class RefOp < Operator
    def execute(stack)
        var = stack.pop
        pointer = Variable.new
        pointer.type = FPLPointer
        pointer.value = Utils.absolutePath(var.path)
        stack.push(pointer)
    end
end

class DerefOp < Operator
    def execute(stack)
        ptr = stack.pop
        ptr.load
        raise FPLError,
              'Deref called on non-pointer' unless ptr.type.is_a? FPLPointer
        var = Variable.new(ptr.value)
        stack.push(var)
    end
end

class OutputOp < Operator
    def execute(stack)
        var = stack.pop
        puts var.value.to_s
    end
end

class InputOp < Operator
    def execute(stack)
        line = STDIN.gets.chomp
        stack.push(Parser.parse(line))
    end
end
