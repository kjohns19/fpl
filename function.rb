require 'parser.rb'
require 'stack.rb'
require 'FileUtils'

class FPLFunction
    def initialize(variable)
        @variable = variable
    end

    def value=(value)
        @value = value
        arr = value.split("\n")
        @args = arr[0].split(' ')
        @code = Parser.parse(arr.drop(1).join("\n"))
    end

    def value
        @value
    end

    def execute(args)
        Dir.mkdir @variable.path
        args.each_with_index do |arg, i|
            varname = @args[i]
            arg.load
            var = Variable.new(File.join(@variable.path, varname))
            var.type = arg.type
            var.value = arg.value
            var.save
        end
        Dir.chdir @variable.path


        stack = Stack.new
        index = 0
        while index < @code.size
            var = @code[index]
            stack.push(var)
            index+=1
        end

        #take top value off stack, put in the file _return in parent directory
        #move up a directory
        #delete the folder
        retval = stack.pop || Variable.new
        retval.load

        Dir.chdir('..')
        ret = Variable.new('_return')
        ret.type = retval.type
        ret.value = retval.value
        ret.save

        FileUtils.rm_r(@variable.path)
    end
end
