
# class changelog(revlog):
#     def __init__(self, repo):
#         self.repo = repo
#         revlog.__init__(self, "00changelog.i", "00changelog.d")
#     def open(self, file, mode="r"):
#         return self.repo.open(file, mode)

#     def extract(self, text):
#         l = mdiff.linesplit(text)
#         manifest = binascii.unhexlify(l[0][:-1])
#         user = l[1][:-1]
#         date = l[2][:-1]
#         last = l.index("\n")
#         files = [f[:-1] for f in l[3:last]]
#         desc = "".join(l[last+1:])
#         return (manifest, user, date, files, desc)

#     def changeset(self, rev):
#         return self.extract(self.revision(rev))
        
#     def addchangeset(self, manifest, list, desc, p1=None, p2=None):
#         try: user = os.environ["HGUSER"]
#         except: user = os.environ["LOGNAME"] + '@' + socket.getfqdn()
#         date = "%d %d" % (time.time(), time.timezone)
#         list.sort()
#         l = [binascii.hexlify(manifest), user, date] + list + ["", desc]
#         text = "".join([e + "\n" for e in l])
#         return self.addrevision(text, p1, p2)

#     def merge3(self, my, other, base):
#         pass

class Changelog < Revlog
    def initialize(repo,path)
        # # self.repo = repo
        #         revlog.__init__(self, "00changelog.i", "00changelog.d")
        Revlog.new("00changelog.i", "00changelog.d")
    end

    def open(file, mode = "r")
        # def open(self, file, mode = "r"):
        # return self.repo.open(file, mode)
    end

    def extract(text)
	#
    end
#
    def changeset(rev)

    end

    def addchangeset(manifest, list, desc, p1=None, p2=None)

    end
end


