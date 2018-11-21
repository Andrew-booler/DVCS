# filelog.rb created by Mingyang 11.4.18
require 'digest'
require_relative 'revlog.rb'

class Filelog < Revlog
    def initialize(repo, path)
        @repo = repo
        sha1 = Digest::SHA1.new
        hex = sha1.update(filename).hexdigest()
        
        hex.gsub("\+", "%")
        hex.gsub("/", "_")     
        index = File.join(path, "index", hex)
        data = File.join(path, "data", hex)
        super(index, data)
    end

    def open(file, mode = "r")
        return @repo.open(file, mode)
    end
end
