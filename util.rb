require_relative 'basic_operators.rb'

class Utils
    def self.base_path=(path)
        @base_path = path
    end

    def self.absolute_path(path)
        File.join(Dir.pwd, path)
    end

    def self.generate_temp_path
        @tp||=0
        @tp += 1
        return File.join(@base_path, "tmp", "#{@tp}")
    end

    def self.generate_heap_path
        @hp||=0
        @hp += 1
        return File.join(@base_path, "heap", "#{@hp}")
    end

    def self.binary_operators
        @bin_ops||=['+', '-', '*', '**', '/', '%', '^', 'and', 'or', 
                    '<', '<=', '>', '>=', '==', '!=']
    end

    def self.unary_operators
        @un_ops||=['!']
    end

    def self.operator(token)
        unless @operators
            @operators = self.binary_operators.map do |op|
                { op => BinaryOp.new(op) }
            end.reduce(:merge).merge(self.unary_operators.map do |op|
                { op => UnaryOp.new(op) }
            end.reduce(:merge))
            @operators.merge!( {
                'put'   => OutputOp.new,
                'get'   => InputOp.new,
                '='     => AssignOp.new,
                'and'   => AndOp.new,
                'or'    => OrOp.new,
                'ref'   => RefOp.new,
                'deref' => DerefOp.new,
                'heap'  => HeapOp.new,
                'delete'=> DeleteOp.new
            } )
        end

        return @operators[token]
    end

    def self.control_keyword(token)
        token.to_sym if [:exit, :then, :while, :else, :end].include? token.to_sym
    end
end
