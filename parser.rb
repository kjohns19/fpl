require 'types.rb'

class Parser
    def parse(str)
        str.scan(/(?:"(?:\\.|[^"])*"|[^" ])+/).map do |token|
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
                op = Utils.operator(token)
                next op if op

                var = Variable.new(token)
            end
            next var
        end
    end
end
