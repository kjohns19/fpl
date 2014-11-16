require_relative 'basic_operators.rb'

class Utils
    def self.base_path=(path)
        @base_path = path
    end

    def self.absolute_path(path)
        path.start_with?('/') ? path : File.join(Dir.pwd, path)
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
        @operators ||= self.binary_operators.map do |op|
            { op => BinaryOp.new(op) }
        end.reduce(:merge).merge(self.unary_operators.map do |op|
            { op => UnaryOp.new(op) }
        end.reduce(:merge)).merge( {
            'put'   => OutputOp.new,
            'get'   => InputOp.new,
            '='     => AssignOp.new,
            '&&'   => AndOp.new,
            '||'    => OrOp.new,
            'ref'   => RefOp.new,
            'deref' => DerefOp.new,
            'heap'  => HeapOp.new,
            'delete'=> DeleteOp.new,
            'pop'   => PopOp.new,
            'call'  => CallOp.new,
            'obj'   => ObjOp.new,
            'at'    => AtOp.new,
            'rand'  => RandOp.new
        } )

        return @operators[token]
    end

    def self.control_keyword(token)
        token.to_sym if [:exit, :fun, :then, :while, :else, :end].include? token.to_sym
    end
end
