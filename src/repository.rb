require 'changelog'
require 'helpers'

class Repository
    @path = ''
    # constructor
    # path-> path to Repo root
    def initialize(path = nil, create = false)
        # create .jsaw folder with all relevant files if required
        path = Dir.pwd + "/" if !path
        @path = path
        @root = path
        if create
            Dir.mkdir(@path+".jsaw")
            # TODO: make other files
        end
        # initilize head changeLog and minifest
        @changeLog = ChangeLog.new(self, @path)
        @manifest = Manifest.new(self, @path)
        # fileLogs???
    end

    def open(path, mode = "r")
        f = join(path)
        if mode == "a" and File.file?(f)
            s = File.stat(f)
            if s.nlink > 1
                # WTFF!!
                # File.open(f+'.tmp', "w")
            end
        return File.open(join(path), mode)
    end

    def join(f)
        return File.join(Dir.pwd, f)
    end

    def file(f)
        return filelog(self, f)
    end
    # commit method
    def commit(message)
        update = []
        delete = []
        begin
            File.open('.jsaw/to-add').each_line{|l| update << l[0..-2]}
            File.open('.jsaw/to-delete'.each_line{|l| delete << l[0..-2]}
        end
        rescue IOError
            p "File error"
        end
        # check in files
        new = {}
        for f in update
            r = filelog(self, f)
            t = file(f).read()
            r.addrevision(t)
            new[f] = r.node(r.tip())
        end
        # update manifest
        old = @manifest.manifest(@manifest.tip())
        old.update(new)
        for f in delete
            old.delete(f)
        end
        rev = @manifest.addmanifest(old)
        # add changeset
        new = new.keys()
        new.sort()
        n = @changeset.addchangeset(@manifest.node(rev), new, "commit")
        @current = n
        # Some sketchy shit
        # unlink path 
    end

    def dirdiff(path)
        st = open("dircache").read()
        dc = {}
        pos = 0

    end

    def add(list)
        addlist = open('to-add', 'a')
        state = open('dircache', 'a')
        for f in list
            addlist.write(f+'\n')
            st = File.stat(f)
            e = [st.mode, st.size, st.mtime, f.length, f]
            e.each{|i| state.write(i)}
        end
    end

    def delete(list)
        delList = open('to-delete', 'a')
        list.each{|f| delList.write(f+'\n')}
    end

end
