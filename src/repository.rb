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
            if File.directory? File.join(Dir.pwd , '.jsaw')
                path = Dir.pwd
            else
                raise "No repo found"
            end

        end

        # create .jsaw folder with all relevant files if required
        # path = Dir.pwd
        @root = path
        @path = File.join(path, '.jsaw')
        if create
            if File.exist?(@path)
                puts "Initialized jsaw repository found at #{@path}"
                return
            end
            Dir.mkdir(@path)
            Dir.mkdir(self.join("data")) unless File.exist?(self.join("data"))
            Dir.mkdir(self.join("index")) unless File.exist?(self.join("index"))
            # create to-add and to-delete
            self.add([])
            self.delete([])
        end
        # initilize head changeLog and minifest
        @manifest = Manifest.new(self)

        @changelog = Changelog.new(self,@manifest)
        begin
            @current = self.open("current").read().to_i
            @heads = eval(self.open("heads").read())
        rescue
            @current = 0
            @heads = [0]
        end
    end

    def getHead()
        puts @heads.inject("heads:\n"){|seq,i|
            seq+@changelog.node(i)+"\n"
        }

    end
    # might not work with path instread of just filenames
    def open(path, mode = "r")
        f = self.join(path)
        if mode == "a" and File.file?(f)
            s = File.stat(f)
            if s.nlink > 1
                File.open(f + '.tmp', 'w+').write(File.open(f).read())
                File.rename(f + '.tmp', f)
            end
        end

        File.open(f, mode)
    end

    def cat(filename, rev)
      change = @changelog.changeset(rev)
      manifest = @manifest.manifest(@manifest.rev(change[0]))
      if manifest.keys().include? filename
        file_rev = manifest[filename]
        r = Filelog.new(self, filename)
        p r.revision(r.rev(file_rev))
      else
        p "the file does not exist in given revision"
      end

      # mmap = self.manifest.manifest(self.manifest.rev(mnode))

      # l = mmap.keys()
      # l.sort()
    end



    def join(f)
        File.join(@path, f)
    end

    def file(f)
        Filelog.new( self, f)
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
        n = @changelog.addchangeset(@manifest.node(rev), new_thing, message)
        File.delete(self.join("to-add")) if File.exist? self.join("to-add")
        File.delete(self.join("to-delete")) if File.exist? self.join("to-delete")
        the_head = 0
        @heads.each_index do |i|
          if @heads[i].eql? @current
              @heads[i]=n
              the_head = 1
              break
          end
        end
        if the_head == 0
            @heads.append(n)
        end
        self.open("heads",'w').write(@heads.to_s)
        @current = n
        self.open("current", "w").write(@current.to_s)
    end

    def checkdir(path)
        dirName = File.dirname(path)
        return if !dirName
        if !File.directory?(dirName)
            self.checkdir(dirName)
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
            r = Filelog.new(self, f)
            t = r.revision(r.rev(mmap[f]))
            if t.length>0
                begin
                    File.open(f, "w").write(t)
                rescue
                    self.checkdir(f)
                    File.open(f, "w").write(t)
                end
            end
            s = File.stat(f)
            e = [s.mode, s.size, s.mtime, f.length, f]
            e.each {|i| st.write(i.to_s + f)}
        }
        @current = rev
        self.open("current", "w").write(@current.to_s)
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
            f1 = Filelog.new(self, f)
            f2 = Filelog.new(self, f)
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
        test = self.open("dircache")
        st = self.open("dircache").each_line {|l|
            split = l.split()
            dc[split[6]] = split
        }
        changed = []
        added = []
        for f in os_walk(@root, '.jsaw')[2]
            f = f.basename.to_s
            stat = File.stat(f)
            if dc.include? f
                temp = dc[f]
                dc.delete(f)
                if temp[1] != stat.size.to_s
                    changed << f
                    p "Changed: #{f}"
                elsif temp[0] != stat.mode.to_s or temp[2] != stat.mtime.to_s
                    # t1 = File.read(f)                   
                    # t2 = self.file(f).revision(@current)
                    # if t1 != t2
                    #     changed << f
                    #     p "Changed: #{f}"
                    # end
                    changed << f
                    p "Changed: #{f}"
                end
            else
                added << f
                p "Untracked File:  #{f}"
            end
        end
        deleted = dc.keys()
        deleted.sort()
        deleted.each {|d| p "Deleted: #{d}"}
        p "STAGING:"
        path = self.join("to-add")
        if File.file?(path)
            self.open("to-add").each_line{|l| p l[0..-2] }
        end

    end

    def remove(list)
        begin
            toadd = self.open("to-add").read()
            dcache = self.open("dircache").readlines()
        rescue
            p "File load error, Repository may not be initialized"
            return 
        end
        for f in list
            if not toadd.include?(f)
                p "#{f} not in staging"
                next
            end
            toadd = toadd.gsub(f+"\n", "" )
            i = dcache.length-1
            while i >= 0
                if dcache[i].include?(f)
                    dcache.delete_at(i)
                    break
                end 
                i -=1
            end

        end
        path = self.join("to-add")
        path2 = self.join("dircache")
        File.open(path + '.tmp', 'w+').write(toadd)
        File.rename(path + '.tmp', path)
        f2 = File.open(path2 + '.tmp', 'w+')
        dcache.each{|l| f2.write(l)}
        File.rename(path2 + '.tmp', path2)
    end

    def add(list)
        begin
            addlist = self.open('to-add', 'a+')
            state = self.open('dircache', 'a')
            addFile = addlist.read
        rescue
            p "File load error, Repository may not be initialized"
            return 
        end
        for f in list
            # check if file exist
            if !File.file?(f)
                p "#{f} does not exist in directory"
                next
            end
            # check for duplicate entry
            next if addFile.include?(f)
            addlist.write(f + "\n")
            st = File.stat(f)
            e = [st.mode, st.size, st.mtime, f.length, f]
            e.each {|i| state.write("#{i} ")}
            state.write("\n")
        end
    end

    def delete(list)
        delList = self.open('to-delete', 'a+')
        delFile = delList.read()
        list.each {|f| 
            next if delFile.include?(f)
            delList.write(f + "\n")
        }

        dcache = self.open("dircache").readlines()
        list.each{|f|
            dcache.each_with_index{|l,i|
                    dcache.delete_at(i) if dcache[i].include?(f) 
                }
        }
        path2 = self.join("dircache")
        f2 = File.open(path2 + '.tmp', 'w+')
        dcache.each{|l| f2.write(l)}
        File.rename(path2 + '.tmp', path2)

    end

end
