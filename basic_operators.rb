require_relative 'operator.rb'
require_relative 'util.rb'
require_relative 'variable.rb'
require_relative 'types.rb'

class BinaryOp < Operator
    def initialize(op)
        @op = op
        @name = op
    end

    attr_reader :name

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
        @name = op
    end

    attr_reader :name

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

    def name
        '&&'
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

    def name
        '||'
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

class ObjOp < Operator
    def num_operands
        0
    end

    def name
        'obj'
    end

    def execute(stack)
        var = Variable.new
        var.type = FPLObject
        var.value = []
        stack.push(var)
    end
end

class RefOp < Operator
    def num_operands
        1
    end

    def name
        'ref'
    end

    def execute(stack)
        var = stack.pop(false)
        pointer = Variable.new
        pointer.type = FPLPointer
        pointer.value = Utils.absolute_path(var.path)
        stack.push(pointer)
    end
end

class DerefOp < Operator
    def num_operands
        1
    end

    def name
        'deref'
    end

    def execute(stack)
        ptr = stack.pop
        #raise FPLError,
        #      'Deref called on non-pointer' unless ptr.type.is_a? FPLPointer
        var = Variable.new(ptr.value)
        stack.push(var)
    end
end

class OutputOp < Operator
    def num_operands
        0
    end

    def name
        'put'
    end

    def execute(stack)
        var = stack.pop
        puts var.value
    end
end 
class InputOp < Operator
    def num_operands
        0
    end

    def name
        'get'
    end

    def execute(stack)
        line = STDIN.gets.chomp
        str = Variable.new
        str.type = FPLString
        str.value = line
        stack.push(str)
    end
end

class EvalOp < Operator
    def num_operands
        1
    end

    def name
        'eval'
    end

    def execute(stack)
        val = stack.pop.value.to_s
        fun = Variable.new(File.join(Dir.pwd, "call"))
        fun.type = FPLFunction
        fun.value = [[], Parser.parse(val)]
        fun.type.execute(stack, true)
    end
end

class AssignOp < Operator
    def num_operands
        0
    end

    def name
        '='
    end

    def execute(stack)
        val = stack.pop
        var = stack.pop(false)
        var.type = val.type.class
        var.value = val.value
        var.save
    end
end

class HeapOp < Operator
    def num_operands
        0
    end

    def name
        'heap'
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

    def name
        'delete'
    end

    def execute(stack)
        val = stack.pop
        val.delete
    end
end

class PopOp < Operator
    def num_operands
        0
    end

    def name
        'pop'
    end

    def execute(stack)
        stack.pop
    end
end

class CallOp < Operator
    def num_operands
        0
    end

    def name
        'call'
    end

    def execute(stack)
        fun = stack.pop
        fun.type.execute(stack)
    end
end

class AtOp < Operator
    def num_operands
        2
    end

    def name
        'at'
    end

    def execute(stack)
        index = stack.pop.value
        obj = stack.pop(false)
        path = File.join(Utils.absolute_path(obj.path), index.to_s)
        stack.push(Variable.new(path))
    end
end

class RandOp < Operator
    def num_operands
        2
    end

    def name
        'rand'
    end

    def execute(stack)
        val1 = stack.pop.value
        val2 = stack.pop.value

        result = Variable.new
        result.type = FPLNumber
        result.value = val2 + rand(val1-val2)
        stack.push(result)
    end
end

class StringOp < Operator
    def num_operands
        1
    end

    def name
        'str'
    end

    def execute(stack)
        val1 = stack.pop.value

        result = Variable.new
        result.type = FPLString
        result.value = val1.to_s
        stack.push(result)
    end
end

class NumOp < Operator
    def num_operands
        1
    end

    def name
        'num'
    end

    def execute(stack)
        val1 = stack.pop.value

        result = Variable.new
        result.type = FPLNumber
        result.value = val1
        stack.push(result)
    end
end

class NullOp < Operator
    def num_operands
        0
    end

    def name
        'null'
    end
    
    def execute(stack)
        stack.push(Variable.new)
    end
end
