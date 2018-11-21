require 'digest'
require_relative 'diff'

sha1 = Digest::SHA1.new
NULLID = sha1.update('').hexdigest

class Revlog
    def initialize(indexfile, datafile)
        @indexfile = indexfile
        @datafile = datafile
        @index = []
        @nodemap = {-1 => NULLID, NULLID => -1}
        begin
            n = 0
            i = self.open(@indexfile).read
            # TODO: does this work?
            i.lines.each do |l|
                e = l
                @nodemap[e[5]] = n
                @index << e
                n += 1
            end
        rescue IOError
        end
    end

    def open(fn, mode = 'r')
        File.open(fn, mode)
    end

    def tip()
        @index.length - 1
    end

    def node(rev)
        rev < 0 and NULLID or @index[rev][5]
    end

    def rev(node)
        @nodemap[node]
    end

    def parents(rev)
        @index[rev][3..5]
    end

    def start(rev)
        @index[rev][0]
    end

    def length(rev)
        @index[rev][1]
    end

    def end(rev)
        start(rev) + length(rev)
    end

    def base(rev)
        @index[rev][2]
    end


    def expand(e1, e2, a1, a2)
        ne = []
        e1.each do |r|
            p1, p2 = self.parents(r)
            p1 if a2.includes? p1
            p2 if a2.includes? p2
            if not a1.includes? p1
                a1[p1] = 1
                ne << p1
                if p2 >= 0 and not a1.includes? p2
                    a1[p2] = 1
                    ne << p2
                end
            end
        end
        expand(e2, ne, a2, a1)
    end

    def ancestor(a, b)
        expand([a], [b], {a: 1}, {b: 1})
    end

    def mergedag(other, accumulate = nil)
        amap = self.nodemap
        bmap = other.nodemap
        old = i = self.tip()
        l = []

        (other.tip() + 1).times.each do |r|
            id = other.node(r)
            if not amap.includes? id:
                                      i += 1
                x, y = other.parents(r)
                xn, yn = [other.node(x), other.node(y)]
                l << [r, amap[xn], amap[yn]]
                amap[id] = i
            end
        end
        r = other.revisions(l.collect {|e| e[0]})
        l.each do |e|
            t = r.next()
            accumulate(t) if accumulate
            self.addrevision(t, e[1], e[2])
        end
        [old, self.tip()]
    end

    def resolvedag(old, new)
        return nil if old == new
        a = self.ancestor(old, new)
        p ''.join(old, new, a)
        return new if old == a
        return self.merge3(old, new, a)
    end

    def merge(other)
        o_n = self.mergedag(other)
        return self.resolvedog(o_n[0], o_n[1])
    end

    def revisions(list)
        list.each {|r| yield(self.revision(r))}
    end

    def revision(rev)
        return "" if rev == -1
        base = self.base(rev)
        start = self.start(base)
        e = self.end(rev)
        f = self.open(@datafile)
        f.seek(start)
        data = f.read(e - start)
        last = self.length(base)
        text = data[0..last]
        for r in (base + 1...rev + 1)
            s = self.length(r)
            b = data[last..last + s]
            text = patch(text, b)
            last = last + s
        end
        parents = self.parents(rev)
        p1 = parents[0]
        p2 = parents[1]
        n1 = self.node(p1)
        n2 = self.node(p2)
        sha1 = Digest::SHA1.new
        node = sha1.update(n1 + n2 + text).hexdigest()
        if self.node(rev) != node
            raise "Consistency check failed on #{self.datafile} : #{rev}"
        end
        return text
    end


    def addrevision(text, p1 = nil, p2 = nil)
        if text == nil
            text = ""
        end
        if p1 == nil
            p1 = self.tip()
        end
        if p2 == nil
            p2 = self.tip()
        end
        t = self.tip()
        n = t + 1

        if n
            start = self.start(self.base(t))
            finish = self.end(t)
            prev = self.revision(t)
            data = DiffUtils.textdiff(prev, text)
        end
        if !n and (finish + len(data) - start) > len(text) * 2
            data = text
            base = n
        else
            base = self.base(t)
        end

        offset = 0
        if t >= 0
            offset = self.end(t)
        end
        n1, n2 = self.node(p1), self.node(p2)
        sha1 = Digest::SHA1.new
        node = sha1.update(n1 + n2 + text).hexdigest()
        e = [offset, len(data), base, p1, p2, node]

        self.index.append(e)
        entry = *e
        # entry = struct.pack(">5l20s", *e)
        self.nodemap[node] = n
        self.open(self.indexfile, "a").write(entry)
        self.open(self.datafile, "a").write(data)
        n
    end

    def merge3(my, other, base)

        def temp(prefix, rev)
            (fd, name) = tempfile.mkstemp(prefix)
            f = File.open(fd, "w")
            f.write(self.revision(my))
            f.close
            name
        end

        a = temp("local", my)
        b = temp("remote", other)
        c = temp("parent", base)

        cmd = ENV['HGMERGE']
        # cmd = os.environ["HGMERGE"]
        r = system("#{cmd} #{a} #{b} #{c}")
        if r
            raise "Merge failed, implement rollback!"
        end
        t = open(a).read()
        self.addrevision(t, my, other)
    end


end