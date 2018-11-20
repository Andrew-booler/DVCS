require_relative "revlog"

class Changelog < Revlog
    def initialize(repo, path)
        index_f = File.join(path, "00changelog.i")
        data_f = File.join(path, "00changelog.d")
        super(index_f, data_f)
    end

    def extract(text)
        p 1234
    end

    def changeset(rev)
        return self.extract(self.revision(rev))
    end

    def add_changeset(manifest, list, desc, p1=nil, p2=nil)
        user = ENV['USER']
        list = list.sort
        time = Time.new
        date = time.inspect + " " + time.zone
        arr = [manifest, user, date]  + list + ["", desc]
        text = arr.join("\n")
        return self.add_revision(text, p1, p2)
    end
end
