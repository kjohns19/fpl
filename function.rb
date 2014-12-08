require_relative 'parser.rb'
require_relative 'stack.rb'
require_relative 'variable.rb'
require 'fileutils.rb'
require_relative 'colors.rb'
require_relative 'types.rb'

class FPLException < StandardError
end
class FPLQuit < StandardError
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

    def execute(prev_stack, use_this_stack = false)
        funcname = FPL_IO.basename(@variable.path)
        funcpath = use_this_stack ? FPL_IO.pwd : FPL_IO.join(FPL_IO.pwd, '0')

        FPL_IO.mkdir funcpath unless use_this_stack
        @args.each do |arg|
            value = prev_stack.pop
            if value
                var = Variable.new(FPL_IO.join(funcpath, arg))
                var.type = value.type.class
                var.value = value.value
                var.save
            else
                puts "No value for #{arg}"
            end
        end
        FPL_IO.goto funcpath unless use_this_stack

        num_pcs = FPL_IO['_pc*'].size
        program_counter = Variable.new("_pc#{num_pcs > 0 ? num_pcs+1 : ''}")
        program_counter.type = FPLNumber
        program_counter.value = 0
        program_counter.save

        flowstack = []

        stack = use_this_stack ? prev_stack : Stack.new
        loop do

            program_counter.load
            index = program_counter.value
            break unless index < @code.size
            var = @code[index]

            begin
                if var.is_a? Symbol
                    #puts "#{index}: #{var}"
                    index = handle_control(var, index, stack, flowstack)
                else
                    #puts "#{index}: #{var.name}"
                    stack.push(var)
                end
            rescue => err
                if err.is_a? FPLQuit
                    raise err
                end
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
            end
            index+=1
            program_counter.value = index
            program_counter.save
        end

        unless stack.empty?
            retval = stack.pop
            ret = Variable.new
            ret.type = retval.type.class
            ret.value = retval.value
            prev_stack.push(ret)
        end

        if use_this_stack
            program_counter.delete
        else
            FPL_IO.goto '..'
            FPL_IO.rm funcpath
        end

    end

    def skip_to(index, syms)
        count = 1
        loop do
            index+=1
            val = @code[index]
            next unless val.is_a? Symbol
            count+=1 if [:while, :then, :fun].include? val
            count-=1 if syms.include?(val) && (count == 1 || val != :else)
            break if count.zero?
        end
        return index
    end

    def handle_control(var, index, stack, flowstack)
        if var == :quit
            raise FPLQuit
        elsif var == :exit
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
            val = stack.pop
            if val.true?
                flowstack << [:while, index]
            else
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

            count = stack.pop.value.to_i
            args = count.times.map { stack.pop(false).name }
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
