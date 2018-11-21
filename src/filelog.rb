require 'digest'
require_relative 'revlog.rb'

class Filelog < Revlog
    def initialize(repo, path)
        @repo = repo
        sha1 = Digest::SHA1.new
        hex = sha1.update(path).hexdigest()

        hex.gsub("\+", "%")
        hex.gsub("/", "_")
        index = File.join("index", hex)
        data = File.join("data", hex)
        super(index, data)
    end

    def open(file, mode = "r")
        @repo.open(file, mode)
    end
end
