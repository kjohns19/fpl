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

        flowstack = []

        stack = Stack.new
        index = 0
        while index < @code.size
            var = @code[index]
            if var.is_a? Symbol
                index = handle_control(var, index, stack, flowstack)
            else
                stack.push(var)
            end
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

    def skip_to(index, syms)
        count = 1
        loop do
            index+=1
            val = @code[index]
            next unless val.is_a? Symbol
            count+=1 if val == :while || val == :then
            count-=1 if syms.include? val
            break if count.zero?
        end
        return index
    end

    def handle_control(var, index, stack, flowstack)
        if var == :end
            last, lastindex = flowstack.pop
            puts "ERROR: end without then/while!" unless last
            if last == :while
                index = lastindex
                needed = 1
                loop do
                    needed-=1
                    index-=1

                    val = @code[index]
                    needed+=val.num_operands if val.is_a? Operator

                    break if needed.zero?
                end
                index-=1
            end
        elsif var == :while
            flowstack << [:while, index]
            val = stack.pop
            if val.false?
                index = skip_to(index+1, [:end])
            end
        elsif var == :then
            flowstack << [:then, index]
            val = stack.pop
            if val.false?
                index = skip_to(index+1, [:end, :else])
            end
        elsif var == :else
            index = skip_to(index+1, [:end])
        end
        return index
    end
end
