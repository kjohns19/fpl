require_relative 'parser.rb'
require_relative 'stack.rb'
require_relative 'variable.rb'
require 'fileutils.rb'
require_relative 'colors.rb'

class FPLException < StandardError
end

class FPLFunction
    def initialize(variable)
        @variable = variable
    end

    def value=(value)
        if value.is_a? String
            @value = value
            arr = value.split("\n")
            @args = arr[0].split(' ')
            @code = Parser.parse(arr.drop(1).join("\n"))
        else
            @args = value[0]
            @code = value[1]
            @value = "#{@args.join(' ')}\n#{@code.map { |v| v.is_a?(Symbol) ? v.to_s : v.name }.join(' ')}"
        end
    end

    def arg_count
        @args.size
    end

    def value
        @value
    end

    def execute(stack)
        funcname = File.basename(@variable.path)
        funcpath = File.join(Dir.pwd, "f_#{funcname}")
        puts "New function #{funcname} from #{Dir.pwd}"

        Dir.mkdir funcpath
        @args.each do |arg|
            value = stack.pop
            if value
                var = Variable.new(File.join(funcpath, arg))
                var.type = value.type.class
                var.value = value.value
                var.save
            else
                puts "No value for #{arg}"
            end
        end
        Dir.chdir funcpath

        flowstack = []

        stack = Stack.new
        index = 0
        while index < @code.size
            var = @code[index]

            begin
                if var.is_a? Symbol
                    puts "#{index}: #{var}"
                    index = handle_control(var, index, stack, flowstack)
                else
                    puts "#{index}: #{var.name}"
                    stack.push(var)
                end
            rescue => err
                unless err.is_a? FPLException
                    puts "Error occurred: #{err}"
                    puts err.backtrace.take(15).join("\n\t")
                    puts "\nFPL Backtrace:\n"
                end
                arr = @code.each_with_index.map do |c, i|
                    c.is_a?(Symbol) ? c.to_s : i == index ? c.name.bold.reverse_color : c.name
                end.join(' ')
                puts "#{funcname}:#{index}:   #{arr}\n\n"
                raise FPLException.new
                exit
            end
            index+=1
        end

        retval = stack.pop || Variable.new

        Dir.chdir('..')
        ret = Variable.new('_return')
        ret.type = retval.type.class
        ret.value = retval.value
        ret.save

        FileUtils.rm_r(funcpath)
    end

    def skip_to(index, syms)
        count = 1
        loop do
            index+=1
            val = @code[index]
            next unless val.is_a? Symbol
            count+=1 if [:while, :then, :fun].include? val
            count-=1 if syms.include? val
            break if count.zero?
        end
        return index
    end

    def handle_control(var, index, stack, flowstack)
        if var == :exit
            return @code.size
        elsif var == :end
            last, lastindex = flowstack.pop
            puts "ERROR: end without then/while!" unless last
            if last == :while
                index = lastindex
                needed = 1
                loop do
                    needed-=1
                    index-=1

                    val = @code[index]
                    if val.is_a? Operator
                        needed+=val.num_operands
                    elsif val.type.is_a? FPLFunction
                        val.load
                        needed+=val.arg_count
                    end

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
                index = skip_to(index+1, [:end, :else])-1
                index+=1 if @code[index+1] == :else
            end
        elsif var == :else
            index = skip_to(index+1, [:end])-1
        elsif var == :fun
            start_i = index+1
            end_i = skip_to(index+1, [:end])-1

            args = stack.pop.value.to_i.times.map { stack.pop(false).name }
            code = @code[start_i..end_i]

            variable = Variable.new
            variable.type = FPLFunction
            variable.value = [args, code]
            stack.push(variable)
            index = end_i+1
        end
        return index
    end
end
