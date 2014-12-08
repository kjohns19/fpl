#!/usr/bin/env ruby
require_relative 'parser.rb'
require_relative 'variable.rb'
require_relative 'function.rb'
require_relative 'stack.rb'
require_relative 'io.rb'
require 'fileutils.rb'

#class FPLException < StandardError
#end
#class FPLQuit < StandardError
#end

code = File.readlines(ARGV[0]).join("")

basedir = FPL_IO.pwd

FPL_IO.rm 'fpl' if FPL_IO.exist? 'fpl'
FPL_IO.mkdir 'fpl'

FPL_IO.goto 'fpl'
Utils.init(FPL_IO.pwd)
main = Variable.new(FPL_IO.join(FPL_IO.pwd, 'main'))
main.type = FPLFunction
main.value = [[], Parser.parse(code)]
main.save

stack = Stack.new
begin
    main.type.execute(stack)
rescue => err
    FPL_IO.goto basedir
    FPL_IO.rm 'fpl'
    raise err unless err.is_a?(FPLException) || err.is_a?(FPLQuit)
    exit
end

heapdir = FPL_IO.join(basedir, 'fpl', 'heap', '*')
heapcontents = FPL_IO[heapdir]
unless heapcontents.empty?
    puts "Contents of heap:"
    heapcontents.each do |file|
        puts "\t#{file}"
    end
end

puts "Return Value: #{stack.pop.value}" unless stack.empty?
FPL_IO.goto ".."
FPL_IO.rm 'fpl'

puts "Total IO operations:"
puts "\tReads:   #{FPL_IO.reads}"
puts "\tWrites:  #{FPL_IO.writes}"
puts "\tDeletes: #{FPL_IO.deletes}"
