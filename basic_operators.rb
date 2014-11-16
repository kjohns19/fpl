require_relative 'operator.rb'
require_relative 'util.rb'
require_relative 'variable.rb'
require_relative 'types.rb'

class BinaryOp < Operator
    def initialize(op)
        @op = op
    end

    def num_operands
        2
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

    def num_operands
        1
    end

    def execute(stack)
        val = stack.pop
        result = val.send(@op)
        stack.push(result)
    end
end

class AndOp < Operator
    def num_operands
        2
    end

    def execute(stack)
        val2 = stack.pop.true?
        val1 = stack.pop.true?
        result = Variable.new
        result.type = FPLBool
        result.value = val1 && val2
        stack.push(result)
    end
end

class OrOp < Operator
    def num_operands
        2
    end

    def execute(stack)
        val2 = stack.pop.true?
        val1 = stack.pop.true?
        result = Variable.new
        result.type = FPLBool
        result.value = val1 || val2
        stack.push(result)
    end
end

class RefOp < Operator
    def num_operands
        1
    end

    def execute(stack)
        var = stack.pop
        pointer = Variable.new
        pointer.type = FPLPointer
        pointer.value = Utils.absolutePath(var.path)
        stack.push(pointer)
    end
end

class DerefOp < Operator
    def num_operands
        1
    end

    def execute(stack)
        ptr = stack.pop
        raise FPLError,
              'Deref called on non-pointer' unless ptr.type.is_a? FPLPointer
        var = Variable.new(ptr.value)
        stack.push(var)
    end
end

class OutputOp < Operator
    def num_operands
        0
    end

    def execute(stack)
        var = stack.pop
        puts var.value
    end
end 
class InputOp < Operator
    def num_operands
        1
    end

    def execute(stack)
        line = STDIN.gets.chomp
        stack.push(Parser.parse(line))
    end
end

class AssignOp < Operator
    def num_operands
        0
    end

    def execute(stack)
        val = stack.pop
        var = stack.pop
        var.type = val.type.class
        var.value = val.value
        var.save
    end
end

class HeapOp < Operator
    def num_operands
        0
    end

    def execute(stack)
        val = Variable.new
        val.type = FPLPointer
        val.value = Utils.generate_heap_path
        stack.push(val)
    end
end

class DeleteOp < Operator
    def num_operands
        0
    end

    def execute(stack)
        val = stack.pop
        val.delete
    end
end
