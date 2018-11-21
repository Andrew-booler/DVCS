require_relative 'changelog'
require_relative 'manifest'
require_relative 'filelog'
require 'pathname'

class Repository
    attr_accessor :path, :root, :changelog, :manifest

    # constructor
    # path-> path to Repo root
    def initialize(path = nil, create = false)

        if path.nil?
            # TODO: fix this
            # while !File.directory? File.join(p, '.jsaw')
            #     p = File.basename(p)
            #     raise "No repo found" if p == "/"
            #     path = p
            # end
        end

        # create .jsaw folder with all relevant files if required
        path = Dir.pwd
        @root = path
        @path = File.join(path, '.jsaw')

        if create
            Dir.mkdir(@path) unless File.exist?(@path)
            Dir.mkdir(self.join("data")) unless File.exist?(self.join("data"))
            Dir.mkdir(self.join("index")) unless File.exist?(self.join("index"))
            # create to-add and to-delete
            self.add([])
            self.delete([])
        end
        # initilize head changeLog and minifest
        @changelog = Changelog.new(self)
        @manifest = Manifest.new(self)
    end

    # might not work with path instread of just filenames
    def open(path, mode = "r")
        f = self.join(path)
        if mode == "a" and File.file?(f)
            s = File.stat(f)
            if s.nlink > 1
                File.open(f + '.tmp', 'w').write(File.open(f).read())
                File.rename(f + '.tmp', f)
            end
        end
        File.open(f, mode)
    end

    def join(f)
        File.join(@path, f)
    end

    def file(f)
        Filelog.new(self, @path, f)
    end

    # commit method
    def commit(message)
        update = []
        delete = []
        begin
            File.open('.jsaw/to-add').each_line {|l| update << l[0..-2]}
        rescue
        end
        begin
            File.open('.jsaw/to-delete').each_line {|l| delete << l[0..-2]}
        rescue
        end
        # check in files
        new_thing = {}
        update.each do |f|
            r = Filelog.new(self, f)
            t = File.open(f).read
            r.addrevision(t)
            new_thing[f] = r.node(r.tip)
        end
        # update manifest
        old = @manifest.manifest(@manifest.tip())
        old.update(new_thing)
        delete.each {|f| old.delete(f)}
        rev = @manifest.addmanifest(old)
        # add changeset
        new_thing = new_thing.keys()
        new_thing.sort()
        n = @changelog.addchangeset(@manifest.node(rev), new_thing, "commit")
        @current = n
        self.open("current", "w").write(@current.to_s)
        File.delete(self.join("to-add")) if File.exist? self.join("to-add")
        File.delete(self.join("to-delete")) if File.exist? self.join("to-delete")
    end

    def checkdir(path)
        dirName = File.basename(path)
        return if !dirName
        if !File.directory?(dirName)
            checkdir(dirName)
            Dir.mkdir(dirName)
        end
    end

    def checkout(rev)
        change = self.changelog.changeset(rev)
        mnode = change[0]
        mmap = self.manifest.manifest(self.manifest.rev(mnode))

        st = self.open("dircache", "w")
        l = mmap.keys()
        l.sort()
        l.each {|f|
            r = Filelog.new(self, @path, f)
            t = r.revision(r.rev(mmap[f]))
            begin
                file(f, "w").write(t)
            rescue
                self.checkdir(f)
                file(f, "w").write(t)
            end

            s = File.stat(f)
            e = [s.mode, s.size, s.mtime, f.length, f]
            e.each {|i| state.write(i + ' ')}
        }
        self.current = change
        self.open("current", "w").write(self.current.to_s)
    end

    def merge(other)
        changed = {}
        n = {}

        def accumulate(text)
            files = self.changelog.extract(text)[3]
            files.each {|f|
                print " #{f} changed"
                changed[f] = 1
            }
        end

        # begin merge of changesets
        print "begining changeset merge"
        co_cn = self.changelog, mergedag(other.changelog, accumulate)
        co = co_cn[0]
        cn = co_cn[1]
        return if co_cn[0] == co_cn[1]

        # merge all files changed by the chnageset,
        # keeping track of the new tips
        changed = chnaged.keys()
        changed.sort()
        changed.each {|f|
            print "merging #{f}"
            f1 = Filelog.new(self, @path, f)
            f2 = Filelog.new(other, @path, f)
            rev = f1.merge(f2)
            n[f] = f1.node(rev) if rev
        }

        # begin merge of manifest
        print "merging manifest"
        mm_mo = self.manifest.mergedag(other.manifest)
        mm = mm_mo[0]
        mo = mm_mo[1]
        ma = self.manifest.ancestor(mm, mo)

        # resolve the manifest to point to all the merged files
        print "resolving manifest"
        mmap = self.manifest.manifest(mm)
        omap = self.manifest.manifest(mo)
        amap = self.manifest.manifest(ma)
        nmap = {}
        mmap.each {|f, mid|
            if omap.key?(f)
                if mid != omap[f]
                    nmap[f] = n.fetch(f, mid)
                else
                    nmap[f] = n.fetch(f, mid)
                end
                omap.delete(f)
            elsif amap.key?(f)
                if mid != amap[f]
                    next
                else
                    next
                end
            else
                nmap[f] = n.fetch(f, mid)
            end
        }
        # del mmap??
        mmap = nil
        omap.each {|f, oid|
            if amap.key?(f)
                if oid != amap[f]
                    next
                else
                    next
                end
            else
                nmap[f] = n.fetch(f, mid)
            end
        }
        # del again..
        omap = nil
        amap = nil

        nm = self.manifest.addmanifest(nmap, mm, mo)
        node = self.manifest.node(nm)
        # Now all files and manifests are merged, we add the changed files
        # and manifest id to the changelog
        print "comitting merge changeset"
        n = n.keys()
        n.sort()
        cn = -1 if co == cn
        self.changelog.addchangeset(node, n, "merge", co, cn)
    end

    def os_walk(dir, ignore)
        root = Pathname(dir)
        files, dirs = [], []
        Pathname(root).find do |path|
            unless path == root
                if !path.to_s.include? ignore
                    dirs << path if path.directory?
                    files << path if path.file?
                end
            end
        end
        [root, dirs, files]
    end

    def diffdir(path)
        dc = {}
        st = self.open("dircache").readline {|l|
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
        deleted.each {|d| p "D #{d}"}

    end

    def add(list)
        addlist = self.open('to-add', 'a')
        state = self.open('dircache', 'a')
        for f in list
            addlist.write(f + "\n")
            st = File.stat(f)
            e = [st.mode, st.size, st.mtime, f.length, f]
            e.each {|i| state.write("#{i} ")}
            state.write("\n")
        end
    end

    def delete(list)
        delList = self.open('to-delete', 'a')
        list.each {|f| delList.write(f + "\n")}
    end

end
