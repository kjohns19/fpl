require_relative 'function.rb'
require_relative 'types.rb'
require_relative 'io.rb'

class Variable
    @@types = { FPLBool:     FPLBool,
                FPLNumber:   FPLNumber,
                FPLString:   FPLString,
                FPLFunction: FPLFunction,
                FPLPointer:  FPLPointer,
                FPLObject:   FPLObject,
                FPLNull:     FPLNull }

    def self.typeFromValue(value)
        case value.class
        when Number
            FPLNumber
        when String
            FPLString
        when Boolean
            FPLBool
        else
            FPLNull
        end
    end

    def initialize(path = nil)
        @path = path
        @type = FPLNull.new(self)
    end

    attr_reader :type
    attr_accessor :path

    def type=(type)
        if type.is_a? String
            @type = @@types[type.to_sym].new(self)
        else
            @type = type.new(self)
        end
    end

    def value
        @type.value
    end

    def value=(value)
        @type.value = value
    end

    def load
        read_variable(self) if @path
    end

    def save
        write_variable(self) if @path
    end

    def delete
        delete_variable(self)
    end

    def is_temp?
        File.basename(File.dirname(path)) == 'tmp'
    end

     Utils.binary_operators.each do |op|
        class_eval "
        def #{op}(variable)
            self.load
            variable.load

            puts \"Self: \#{self.value}\"
            puts \"Var:  \#{variable.value}\"
            puts \"Op: #{op}\"
            val = self.value.send(#{op.inspect}, variable.value)

            result = Variable.new
            result.type = typeFromValue(val)
            result.value = val
            return result
        end"
     end
     Utils.unary_operators.each do |op|
        class_eval "
        def #{op}
            self.load
            val = self.value.send(#{op.inspect})

            result = Variable.new
            result.type = typeFromValue(val)
            result.value = val
            return result
        end"
     end
end
