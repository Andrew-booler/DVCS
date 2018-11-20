# filelog.rb created by Mingyang 11.4.18
require 'digest'
require_relative 'revlog.rb'

class Filelog < Revlog
    def initialize(repo, path, filename)
        @repo = repo
        sha1 = Digest::SHA1.new
        hex = sha1.update(filename).hexdigest()

        index = File.join(path, "index", hex)
        data = File.join(path, "data", hex)
        super(index, data)
    end

    def open(file, mode = "r")
        # def open(self, file, mode = "r"):
        # return self.repo.open(file, mode)
    end
end
