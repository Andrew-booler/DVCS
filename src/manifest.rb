require 'digest'
require_relative 'revlog.rb'

class Manifest < Revlog
    def initialize(repo)
        @repo = repo
        Revlog.new("00manifest.i", "00manifest.d")
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
        file_map.each {|name, name_hash| arr << name.to_s + ' ' + name_hash.to_s}
        text = arr.join("\n")
        self.addrevision(text, p1, p2)
    end
end
