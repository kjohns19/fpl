require_relative 'types.rb'
require_relative 'variable.rb'
require_relative 'util.rb'

class Parser
    def self.parse(str)
        str.split("\n").reject { |s| s.start_with? '#' }.join(' ').
        scan(/(?:"(?:\\.|[^"])*"|[^" ])+/).map do |token|
            #puts "Token: <#{token}>"
            var = nil
            if token =~ /^\d+(\.\d+)?$/
                var = Variable.new(nil, token)
                var.type = FPLNumber
                var.value = token
            elsif token =~ /^".*"$/
                var = Variable.new(nil, token)
                var.type = FPLString
                var.value = token[1..-2].gsub('\n',"\n").
                                         gsub('\t',"\t").
                                         gsub('\"','"')
            elsif token == 'true' || token == 'false'
                var = Variable.new(nil, token)
                var.type = FPLBool
                var.value = token
            else
                var = Utils.operator(token)
                var||=Utils.control_keyword(token)
                var||=Variable.new(token.gsub('.', '/'), token)
            end
            next var
        end
    end
end
