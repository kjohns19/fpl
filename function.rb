require_relative 'parser.rb'
require_relative 'stack.rb'
require_relative 'variable.rb'
require 'fileutils.rb'

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

    def execute(stack)
        Dir.mkdir @variable.path
        @args.each do |arg|
            value = stack.pop
            var = Variable.new(File.join(@variable.path, arg))
            var.type = value.type.class
            var.value = value.value
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

        retval = stack.pop || Variable.new

        Dir.chdir('..')
        ret = Variable.new('_return')
        ret.type = retval.type.class
        ret.value = retval.value
        ret.save

        FileUtils.rm_r(@variable.path)
    end
end
