require 'basic_operators.rb'

class Utils
    def self.base_path=(path)
        @base_path = path
    end

    def self.absolute_path(path)
        File.join(Dir.pwd, path)
    end

    def self.generate_temp_path
        @p||=0
        @p += 1
        return File.join(@base_path, "tmp", "#{@p}")
    end

    def self.binary_operators
        @bin_ops||=['+', '-', '*', '**', '/', '%', '^', '&&', '||',
                    '<', '<=', '>', '>=', '==', '!=']
    end

    def self.unary_operators
        @un_ops||=['!']
    end

    def self.operator(token)
        unless @operators
            @operators = self.binary_operators.map do |op|
                { op => BinaryOperator.new(op) }
            end.reduce(:merge).merge(self.unary_operators.map do |op|
                { op => UnaryOperator.new(op) }
            end.reduce(:merge))
            @operators.merge!( {
                'get' => OutputOp.new
                'put' => InputOp.new
            } )
        end

        return @operators[token]
    end
end
