require 'digest'
require_relative 'revlog.rb'

class Manifest < Revlog
    def initialize(repo)
        @repo = repo
        super("00manifest.i", "00manifest.d")
    end

    def open(file, mode = "r")
        @repo.open(file, mode)
    end

    def manifest(rev)
        text = self.revision(rev)
        map = {}
        text.lines.each do |line|
            name, name_hash = line.split(" ")
            map[name] = name_hash
        end
        return map
    end

    def addmanifest(filemap, p1 = nil, p2 = nil)
        files = filemap.keys
        files.sort!
        arr = []
        files.each {|name| arr << filemap[name].to_s + ' ' + name.to_s}
        text = arr.join("\n")
        # p files
        # p arr
        # p text
        self.addrevision(text, p1, p2)
    end
end
