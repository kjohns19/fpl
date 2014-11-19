require_relative 'types.rb'
require 'fileutils.rb'

module FPLIO
    def self.read_variable(variable)
        @num_read||=0
        @num_read+=1
        #puts "Reading from #{variable.path}"
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
            raise "File #{variable.path} doesn't exist!"
            variable.type = FPLNull
            variable.value = nil
        end
    end

    def self.write_variable(variable)
        @num_write||=0
        @num_write+=1
        #puts "Saving #{variable.value} to #{variable.path}"
        if variable.type.is_a? FPLObject 
            FileUtils.rm_r variable.path if File.exist? variable.path
            Dir.mkdir variable.path
            variable.value.each do |v|
                old = nil
                if v.is_a? String
                    old = Variable.new(v)
                    old.load
                else
                    old = v
                end
                newpath = File.join(variable.path, File.basename(old.path))
                var = Variable.new(newpath)
                var.type = old.type.class
                var.value = old.value
                var.save
            end
        else
            File.open(variable.path, "w") do |f|
                f.puts(variable.type.class.name)
                f.puts(variable.value)
            end
        end
    end

    def self.delete_variable(variable)
        @num_delete||=0
        @num_delete+=1
        #puts "Deleting #{variable.path}"
        FileUtils.rm_r(variable.path)
    end

    def self.reads
        @num_read||=0
    end
    def self.writes
        @num_write||=0
    end
    def self.deletes
        @num_delete||=0
    end
end
