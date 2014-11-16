class FPLBool
    attr_reader :value

    def initialize(variable)
        @variable = variable
    end

    def value=(value)
        @value = (value.to_s == 'true') ? true : false
    end
end

class FPLNumber
    attr_reader :value

    def initialize(variable)
        @variable = variable
    end

    def value=(value)
        @value = value.to_f
    end
end

class FPLString
    attr_accessor :value

    def initialize(variable)
        @variable = variable
    end
end

class FPLPointer
    attr_accessor :value

    def initialize(variable)
        @variable = variable
    end
end

class FPLObject
    attr_accessor :value

    def initialize(variable)
        @variable = variable
    end
end

class FPLNull
    attr_accessor :value

    def initialize(variable)
        @variable = variable
    end
end
