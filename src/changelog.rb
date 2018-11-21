require_relative 'revlog'
require_relative 'diff'

class Changelog < Revlog
    def initialize(repo)
      @repo = repo
      super( "00changelog.i", "00changelog.d")
    end

    def open(file, mode="r")
        return @repo.open(file, mode)
    end

    def extract(text)
      l = DiffUtils.linesplit(text)
      manifest = l[0][0..-2]
      user = l[1][0..-2]
      date = l[2][0..-2]
      last = l.index("\n")
      files = l[3..last].collect {|f| f[0..-2]}
      desc = "".join(l[last+1..-1])
      [manifest, user, date, files, desc]
    end

    def changeset(rev)
        self.extract(self.revision(rev))
    end

    def addchangeset(manifest, list, desc, p1=nil, p2=nil)
      user = ENV['USER']
      list = list.sort
      time = Time.new
      date = time.inspect + " " + time.zone
      arr = [manifest, user, date]  + list + ["", desc]
      text = arr.join("\n")
      self.addrevision(text, p1, p2)
    end

    def merge3(my, other, base)
      pass
    end

end
