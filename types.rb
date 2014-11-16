class FPLBool
    attr_reader :value

    def value=(value)
        @value = value == 'false' ? false : true
    end
end

class FPLNumber
    attr_reader :value

    def value=(value)
        @value = value.to_f
    end
end

class FPLString
    attr_accessor :value
end

class FPLPointer
    attr_accessor :value
end

class FPLObject
    attr_accessor :value
end
