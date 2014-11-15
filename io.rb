require 'FileUtils'
require 'object.rb'

def read_variable(variable)
    begin
        contents = File.readlines(variable.path)
        variable.type = contents[0]
        variable.value = contents.drop(1).join("\n")
    rescue
        variable.type = FPLNull
        variable.value = nil
    end
end

def write_variable(variable)
    if variable.type.is_a? Object 
        Dir.mkdir variable.path
        variable.value.each { |v| write_variable(v) }
    else
        File.open(variable, "w") do |f|
            f.puts(variable.type)
            f.puts(variable.value)
        end
    end
end

def delete_variable(variable)
    FileUtils.rm_r(variable.path)
end
