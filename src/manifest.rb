require 'digest'
require_relative 'revlog.rb'

class Manifest < Revlog
    def initialize(repo)
        @repo = repo
        super("00manifest.i", "00manifest.d")
        if self.index.length==0
            self.addmanifest({}, p1 = nil, p2 = nil)
        end
    end
    
    def open(file, mode = "r")
        @repo.open(file, mode)
    end

    def manifest(rev)
        text = self.revision(rev)
        map = {}
        text.lines.each do |line|
            name_hash, name = line.split(" ")
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
        self.addrevision(text, p1, p2)
    end
end
