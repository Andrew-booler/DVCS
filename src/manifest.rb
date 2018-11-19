# filelog.rb created by Mingyang 11.4.18
require 'digest'

class Manifest < Revlog
    def initialize(repo,path)
        @repo = repo
        Revlog.new("00manifest.i", "00manifest.d")
    end

    def open(file, mode = "r")
        return @repo.open(file, mode)
    end

    def manifest(rev)
        text = self.revision(rev)
        hash = {}
        text.lines.each do |line|
            name,name_hash = line.split(" ")
            hash[name] = name_hash
        end
        return hash
    end

    def add_manifest(file_map, p1 = nil, p2 = nil)
        file_map = file_map.sort
        arr = []
        file_map.each {|name, name_hash| arr << name + " " + name_hash}
        text = arr.join("\n")
        return self.addrevision(text,p1,p2)
    end
end
