require_relative "revlog"

class Changelog < Revlog
    def initialize(repo,path)
        #     index_file = File.join(path, "00manifest.i")
        # data_file = File.join(path, "00manifest.d")
        # super(index_file, data_file)      
        Revlog.new("00changelog.i", "00changelog.d")
        @repo = repo
    end

    def open(file, mode = "r")
        return self.repo.open(file, mode)
    end

    def extract(text)
	   
    end

    def changeset(rev)
        return self.extract(self.revision(rev))
    end

    def addchangeset(manifest, list, desc, p1=None, p2=None)
        user = ENV['USER']
        list = list.sort
        time = Time.new
        date = time.inspect + " " + time.zone
        arr = [manifest, user, date]  + list + ["", desc]
        text = arr.join("\n")
        return self.addrevision(text, p1, p2)
    end
end
