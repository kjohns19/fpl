#!/usr/bin/env ruby
require_relative 'parser.rb'
require_relative 'variable.rb'
require_relative 'function.rb'
require_relative 'stack.rb'
require 'fileutils.rb'

code = File.readlines(ARGV[0]).join("")
#puts code
#puts
basedir = Dir.pwd
FileUtils.mkdir_p 'fpl/tmp'
FileUtils.mkdir_p 'fpl/heap'
Dir.chdir 'fpl'
Utils.base_path = Dir.pwd
main = Variable.new(File.join(Dir.pwd, "main"))
main.type = FPLFunction
main.value = [[], Parser.parse(code)]

stack = Stack.new
begin
    main.type.execute(stack)
rescue => err
    Dir.chdir basedir
    FileUtils.rm_r('fpl')
    exit
end

puts "Return Value: #{stack.pop.value}"
Dir.chdir ".."
FileUtils.rm_r('fpl')
