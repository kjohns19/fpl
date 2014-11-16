require_relative 'types.rb'
require 'fileutils.rb'

def read_variable(variable)
    puts "Reading from #{variable.path}"
    begin
        # If directory, type is object, value is list of variables in folder
        if File.directory?(variable.path)
            variable.type = FPLObject
            variable.value = Dir[File.join(variable.path, '*')]
        else
            contents = File.readlines(variable.path)
            variable.type = contents[0].chomp
            variable.value = contents.drop(1).join("").chomp
        end
    rescue
        puts "File #{variable.path} doesn't exist!"
        variable.type = FPLNull
        variable.value = nil
    end
end

def write_variable(variable)
    puts "Saving #{variable.value} to #{variable.path}"
    if variable.type.is_a? FPLObject 
        Dir.mkdir variable.path
        variable.value.each { |v| write_variable(v) }
    else
        File.open(variable.path, "w") do |f|
            f.puts(variable.type.class.name)
            f.puts(variable.value)
        end
    end
end

def delete_variable(variable)
    puts "Deleting #{variable.path}"
    FileUtils.rm_r(variable.path)
end
