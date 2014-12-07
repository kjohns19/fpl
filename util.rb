require_relative 'basic_operators.rb'

class Folder
    def initialize(path, name)
        @dir = File.join(path, name)
        FileUtils.mkdir_p @dir

        count = Variable.new(File.join(@dir, 'count'))
        count.type = FPLNumber
        count.value = 0
        count.save
    end

    def create_path
        count = Variable.new(File.join(@dir, 'count'))
        count.load
        count.value+=1
        count.save
        return File.join(@dir, count.value.to_s)
    end
end

module Utils
    def self.init(path)
        @base_path = path
        @heap = Folder.new(path, '_heap')
        @tmp = Folder.new(path, '_tmp')
    end

    def self.absolute_path(path)
        path.start_with?('/') ? path : File.join(Dir.pwd, path)
    end

    def self.generate_temp_path
        return @tmp.create_path
    end

    def self.generate_heap_path
        return @heap.create_path
    end

    def self.binary_operators
        @bin_ops||=['+', '-', '*', '**', '/', '%', '^',
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
            '&&'    => AndOp.new,
            '||'    => OrOp.new,
            'ref'   => RefOp.new,
            'deref' => DerefOp.new,
            'heap'  => HeapOp.new,
            'delete'=> DeleteOp.new,
            'pop'   => PopOp.new,
            'call'  => CallOp.new,
            'obj'   => ObjOp.new,
            'at'    => AtOp.new,
            'rand'  => RandOp.new,
            'str'   => StringOp.new,
            'num'   => NumOp.new,
            'null'  => NullOp.new,
            'eval'  => EvalOp.new,
            'sleep' => SleepOp.new,
            'exists'=> ExistOp.new
        } )

        return @operators[token]
    end

    def self.control_keyword(token)
        token.to_sym if [:quit, :exit, :fun, :then, :while, :else, :end].include? token.to_sym
    end
end
