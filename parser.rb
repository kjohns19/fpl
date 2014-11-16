require_relative 'types.rb'
require_relative 'variable.rb'
require_relative 'util.rb'

class Parser
    def self.parse(str)
        str.split("\n").join(' ').scan(/(?:"(?:\\.|[^"])*"|[^" ])+/).map do |token|
            #puts "Token: <#{token}>"
            var = nil
            if token =~ /^\d+(\.\d+)?$/
                var = Variable.new
                var.type = FPLNumber
                var.value = token
            elsif token =~ /^".*"$/
                var = Variable.new
                var.type = FPLString
                var.value = token[1..-2]
            elsif token == 'true' || token == 'false'
                var = Variable.new
                var.type = FPLBool
                var.value = token
            else
                var = Utils.operator(token)
                var||=Utils.control_keyword(token)
                var||=Variable.new(token.gsub(',', '/'))
            end
            next var
        end
    end
end
