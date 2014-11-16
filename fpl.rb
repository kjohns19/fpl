#!/usr/bin/env ruby
require_relative 'parser.rb'
require_relative 'variable.rb'
require_relative 'function.rb'

code = File.readlines(ARGV[0]).join("\n")
Dir.mkdir "fpl"
Dir.chdir "fpl"
Dir.mkdir "tmp"
Dir.mkdir "heap"
Utils.base_path = Dir.pwd
main = Variable.new(File.join(Dir.pwd, "main"))
main.type = FPLFunction
main.value = "\n#{code}"
main.type.execute([])
puts "Return Value:"
puts File.readlines("_return").join("\n")
Dir.chdir ".."
