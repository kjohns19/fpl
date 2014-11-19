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
                FPLNull:     FPLNull
    }

    def self.typeFromValue(value)
        if value.is_a? Numeric
            return FPLNumber
        elsif value.is_a? String
            return FPLString
        elsif value.is_a?(TrueClass) || value.is_a?(FalseClass)
            return FPLBool
        else
            return FPLNull
        end
    end

    def initialize(path = nil, name = nil)
        @path = path
        @name = name
        @type = FPLNull.new(self)
    end

    def name
        @name ? @name : File.basename(@path)
    end

    attr_reader :type
    attr_accessor :path

    def type=(type)
        if type.is_a? String
            @type = @@types[type.to_sym].new(self)
        else
            @type = type.new(self)
        end
        #puts "Type = #{type}"
    end

    def value
        @type.value
    end

    def value=(value)
        @type.value = value
        #puts "Value = #{self.value}"
    end

    def true?
        !false?
    end

    def false?
        type.is_a?(FPLNull) || (type.is_a?(FPLBool) && !value)
    end

    def load
        FPLIO.read_variable(self) if @path
    end

    def save
        FPLIO.write_variable(self) if @path
    end

    def delete
        FPLIO.delete_variable(self)
    end

    def is_temp?
        File.basename(File.dirname(path)) == '_tmp'
    end

     Utils.binary_operators.each do |op|
        class_eval "
        def #{op}(variable)
            #puts \"Self: \#{self.value}\"
            #puts \"Var:  \#{variable.value}\"
            #puts \"Op: #{op}\"
            val = self.value.send(#{op.inspect}, variable.value)

            result = Variable.new
            result.type = Variable.typeFromValue(val)
            result.value = val
            return result
        end"
     end
     Utils.unary_operators.each do |op|
        class_eval "
        def #{op}
            val = self.value.send(#{op.inspect})

            result = Variable.new
            result.type = Variable.typeFromValue(val)
            result.value = val
            return result
        end"
     end
end
