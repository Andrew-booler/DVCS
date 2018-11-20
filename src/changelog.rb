require_relative "revlog"

class Changelog < Revlog
    def initialize(repo, path)
        index_file = File.join(path, "00changelog.i")
        data_file = File.join(path, "00changelog.d")
        super(index_file, data_file)
    end

    def extract(text)

    end

    def changeset(rev)
        return self.extract(self.revision(rev))
    end

    def add_changeset(manifest, list, desc, p1=None, p2=None)
        user = ENV['USER']
        list = list.sort
        time = Time.new
        date = time.inspect + " " + time.zone
        arr = [manifest, user, date]  + list + ["", desc]
        text = arr.join("\n")
        return self.addrevision(text, p1, p2)
    end
end
