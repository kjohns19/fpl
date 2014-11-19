#!/usr/bin/env ruby
require_relative 'parser.rb'
require_relative 'variable.rb'
require_relative 'function.rb'
require_relative 'stack.rb'
require_relative 'io.rb'
require 'fileutils.rb'

code = File.readlines(ARGV[0]).join("")
basedir = Dir.pwd
FileUtils.mkdir_p 'fpl'
Dir.chdir 'fpl'
Utils.init(Dir.pwd)
main = Variable.new(File.join(Dir.pwd, 'main'))
main.type = FPLFunction
main.value = [[], Parser.parse(code)]
main.save

stack = Stack.new
begin
    main.type.execute(stack)
rescue => err
    Dir.chdir basedir
    FileUtils.rm_r('fpl')
    exit
end

heapdir = File.join(basedir, 'fpl', 'heap', '*')
heapcontents = Dir[heapdir]
unless heapcontents.empty?
    puts "Contents of heap:"
    heapcontents.each do |file|
        puts "\t#{file}"
    end
end

puts "Return Value: #{stack.pop.value}" unless stack.empty?
Dir.chdir ".."
FileUtils.rm_r('fpl')

puts "Total IO operations:"
puts "\tReads:   #{FPLIO.reads}"
puts "\tWrites:  #{FPLIO.writes}"
puts "\tDeletes: #{FPLIO.deletes}"
