# filelog.rb created by Mingyang 11.4.18
require 'digest'

class Filelog < Revlog
    def initialize(repo,path)
        # # self.repo = repo
        sha1 = Digest::SHA1.new
        dir = sha1.update(path).hexdigest()
        
        index_dir = File.join(dir, "index")
        data_dir = File.join(dir, "data")
        #
        p index_dir
        p data_dir
        
        Revlog.new(index_dir, data_dir)
    end

    def open(file, mode = "r")
        # def open(self, file, mode = "r"):
        # return self.repo.open(file, mode)
    end
end

Filelog.new(repo = 6,"/Users/jiao/Desktop/DVCS")
