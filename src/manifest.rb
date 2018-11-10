# filelog.rb created by Mingyang 11.4.18
require 'digest'


# class manifest(revlog):
#     def __init__(self, repo):
#         self.repo = repo
#         revlog.__init__(self, "00manifest.i", "00manifest.d")
#     def open(self, file, mode="r"):
#         return self.repo.open(file, mode)
#     def manifest(self, rev):
#         text = self.revision(rev)
#         map = {}
#         for l in mdiff.linesplit(text):
#             map[l[41:-1]] = binascii.unhexlify(l[0:40])
#         return map
#     def addmanifest(self, map, p1=None, p2=None):
#         files = map.keys()
#         files.sort()
#         text = "".join(["%s %s\n" % (binascii.hexlify(map[f]), f)
#                         for f in files])
#         return self.addrevision(text, p1, p2)

class Manifest < Revlog
    def initialize(repo,path)
        # # self.repo = repo
        Revlog.new("00manifest.i", "00manifest.d")
    end

    def open(file, mode = "r")
        # def open(self, file, mode = "r"):
        # return self.repo.open(file, mode)
    end

    def manifest(rev)
        text = self.revision(rev)
        # map = {}
        # for l in mdiff.linesplit(text):
        #     map[l[41:-1]] = binascii.unhexlify(l[0:40])
        # return map     
        hash = {}
        text.split("\n").each do |e|
            key = e.split(" ")[0]
            value = e.split(" ")[1]
            hash[key] = value
        end
        return hash
    end

    def add_manifest(hash, p1 = nil, p2 = nil)
        #         files = map.keys()
        # files.sort()
        # text = "".join(["%s %s\n" % (binascii.hexlify(map[f]), f)
        #                 for f in files])
        # return self.addrevision(text, p1, p2)
        hash = hash.sort
        hash.each {|key, value| arr << key + " " + value}
        text = arr.join("\n")
        return self.addrevision(text,p1,p2)
    end
end

# Filelog.new(repo = 6,"/Users/jiao/Desktop/DVCS")
