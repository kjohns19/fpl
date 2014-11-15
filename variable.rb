class Variable
    @@types = { bool:     FPLBool,
                number:   FPLNumber,
                string:   FPLString,
                function: FPLFunction,
                pointer:  FPLPointer,
                object:   FPLObject }
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

    def initialize(path)
        @path = path
        @type = FPLNull.new
    end

    attr_reader :type
    attr_accessor :path

    def type=(type)
        if type.is_a? String
            @type = @@types[type.to_sym].new
        else
            @type = type.new
        end
    end

    def value
        @type.value
    end

    def value=(value)
        @type.set(value)
    end

    def load
        read_variable(self)
    end

    def save
        write_variable(self)
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

            val = self.value.send(#{op.inspect}, value.value)

            result = Variable.new(nil)
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

            result = Variable.new(nil)
            result.type = typeFromValue(val)
            result.value = val
            return result
        end"
     end
end
