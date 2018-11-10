require_relative 'changelog'
require_relative 'helpers'

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
        @changelog = ChangeLog.new(self, @path)
        @manifest = Manifest.new(self, @path)
        # fileLogs???
    end

    # might not work with path instread of just filenames 
    def open(path, mode = "r")
        f = join(path)
        if mode == "a" and File.file?(f)
            s = File.stat(f)
            if s.nlink > 1
                File.open(f+'.tmp', 'w').write(File.open(f).read())
                File.rename(f+'.tmp', f)
            end
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
        rescue IOError
            p "to-add file error"
            update = false
        end
        begin
            File.open('.jsaw/to-delete').each_line{|l| delete << l[0..-2]}
        rescue
            p "to-delete file error"
            delete = false
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
        delete.each{|f| old.delete(f) }
        rev = @manifest.addmanifest(old)
        # add changeset
        new = new.keys()
        new.sort()
        n = @changeset.addchangeset(@manifest.node(rev), new, "commit")
        @current = n
        self.open("current", "w").write(@current.to_s)
        File.delete(self.join("to-add")) if update
        File.delete(self.join("to-delete")) if delete
    end

    def dirdiff(path)
        dc = {}
        pos = 0
        st = open("dircache").readline{|l|
            split = l.split()
            dc[split[4]] = split
        }
        changed = []
        added = []
        for f in os_walk(@root, '.jsaw')[2]
            stat = File.stat(f)
            if dc.include? f
                temp = dc[f]
                dc.delete[f]
                if temp[1] != stat.size
                    changed << f
                    p "C #{f}"
                elsif temp[0] != stat.mode or temp[2] != stat.mtime
                    t1 = File.read(f)
                    # may not work with path instread of file name 
                    t2 = self.file(f).revision(@current)
                    if t1 != t2
                        changed << f
                        p "C #{f}"
                    end
                end
            else
                added << f
                p "A #{f}"
            end
        end
        deleted = dc.keys()
        deleted.sort()
        deleted.each{|d| p "D #{d}"}        
        
    end

    def add(list)
        addlist = open('to-add', 'a')
        state = open('dircache', 'a')
        for f in list
            addlist.write(f+'\n')
            st = File.stat(f)
            e = [st.mode, st.size, st.mtime, f.length, f]
            e.each{|i| state.write(i+' ')}
        end
    end

    def delete(list)
        delList = open('to-delete', 'a')
        list.each{|f| delList.write(f+'\n')}
    end

end
