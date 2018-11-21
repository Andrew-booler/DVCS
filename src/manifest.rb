# filelog.rb created by Mingyang 11.4.18
require 'digest'
require_relative 'revlog.rb'

class Manifest < Revlog
    def initialize(repo, path)
        index_file = File.join(path, "00manifest.i")
        data_file = File.join(path, "00manifest.d")
        super(index_file, data_file)
    end

    def manifest(rev)
        text = self.revision(rev).get_content()
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
        file_map.each {|name, name_hash| arr << name.to_s + " " + name_hash.to_s}
        text = arr.join("\n")
        return self.add_revision(Revnode.new(text),p1,p2)
    end
end
