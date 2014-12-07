require_relative 'operator.rb'
require_relative 'util.rb'
require_relative 'types.rb'

require 'fileutils.rb'

class Stack
    def initialize
        @dir = File.join(Dir.pwd, '_stack')
        FileUtils.mkdir_p @dir
        sizeVar = Variable.new(File.join(@dir, 'size'))
        sizeVar.type = FPLNumber
        sizeVar.value = 0
        sizeVar.save
        #puts "New stack created at #{@dir}"
    end

    def push(val)
        if val.is_a? Operator
            val.execute(self)
        else
            if val.path
                if val.path[0] != '/'
                    val.path = Utils.absolute_path(val.path)
                end
            else
                val.path = Utils.generate_temp_path
            end
            sizeVar = Variable.new(File.join(@dir, 'size'))
            sizeVar.load

            ptr = Variable.new(File.join(@dir, sizeVar.value.to_s))
            ptr.type = FPLPointer
            ptr.value = val.path
            ptr.save

            #puts "Pushing #{val.path} to #{@dir}"

            sizeVar.value+=1
            sizeVar.save

            val.save if val.is_temp?
        end
    end

    def pop(do_load = true)
        mysize = sizeVar
        if mysize.value > 0
            mysize.value-=1
            mysize.save
            ptr = Variable.new(File.join(@dir, mysize.value.to_s))
            ptr.load
            var = Variable.new(ptr.value)
            var.load(true) if do_load
            if var.is_temp?
                var.delete
            end
            ptr.delete
        else
            puts 'Trying to pop from empty stack'
        end

        #puts "Popped #{var.path} from #{@dir}"
        return var
    end

    def size
        sizeVar.value
    end

    def empty?
        self.size == 0
    end

private
    def sizeVar
        mysize = Variable.new(File.join(@dir, 'size'))
        mysize.load
        return mysize
    end
end
