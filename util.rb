class Utils
    def self.base_path=(path)
        @base_path = path
    end

    def self.absolute_path(path)
        File.join(Dir.pwd, path)
    end

    def self.generate_temp_path
        @p||=0
        @p += 1
        return File.join(@base_path, "tmp", "#{@p}")
    end

    def self.binary_operators
        @bin_ops||=['+', '-', '*', '**', '/', '%', '^', '&&', '||',
                    '<', '<=', '>', '>=', '==', '!=']
    end

    def self.binary_operators
        @un_ops||=['!', 'ref', 'deref']
    end
end
