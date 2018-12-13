require 'digest'
require 'json'
require_relative 'diff'

sha1 = Digest::SHA1.new
NULLID = sha1.update('').hexdigest

class Revlog
    # for testing purposes only
    attr_reader :indexfile, :datafile, :index, :nodemap

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
                e = l.split(' ')
                (e.length-1).times do |i|
                    e[i] = e[i].to_i
                end
                @nodemap[e[5]] = n
                @index << e
                n += 1
            end
        rescue
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

    def finish(rev)
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
            unless a1.includes? p1
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
        expand([a], [b], {a => 1}, {b => 1})
    end

    def mergedag(other)
        amap = self.nodemap
        bmap = other.nodemap
        old = i = self.tip()
        l = []

        (other.tip() + 1).times.each do |r|
            id = other.node(r)
            unless amap.includes? id
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
            yield t if block_given?
            self.addrevision(t, e[1], e[2])
        end
        [old, self.tip()]
    end

    def resolvedag(old, new)
        return nil if old == new
        a = self.ancestor(old, new)
        p ', '.join(old, new, a)
        return new if old == a
        self.merge3(old, new, a)
    end

    def merge(other)
        o_n = self.mergedag(other)
        self.resolvedog(o_n[0], o_n[1])
    end

    def revisions(list)
        list.each {|r| yield(self.revision(r))}
    end

    def revision(rev)
        return "" if rev == -1
        base = self.base(rev)
        start = self.start(base)
        e = self.finish(rev)
        f = self.open(@datafile)
        f.seek(start)
        data = f.read(e - start)
        last = self.length(base)
        text = JSON.parse data[0...last]
        for r in (base + 1...rev + 1)
            s = self.length(r)
            b = data[last...last + s]
            b_arr = JSON.parse b
            text = DiffUtils.patch(text, b_arr).join("")
            last = last + s
        end
        parents = self.parents(rev)
        p1 = parents[0]
        p2 = parents[1]
        n1 = self.node(p1)
        n2 = self.node(p2)
        sha1 = Digest::SHA1.new
        node = sha1.update(n1 + n2 + text).hexdigest
        if self.node(rev) != node
            raise "Consistency check failed on #{@datafile} : #{rev}"
        end
        text
    end


    def addrevision(text, p1 = nil, p2 = nil)
        text = '' if text.nil?
        p1 = tip if p1.nil?
        p2 = tip if p2.nil?

        t = tip
        n = t + 1

        if n != 0
            start = self.start(base(t))
            finish = self.finish(t)
            prev = revision(t)
            data = DiffUtils.textdiff(prev, text).to_s
        end
        # p text.to_s
        if n == 0 or (finish + data.length - start) > text.to_s.length * 2
            data = text.dump
            base = n
        else
            base = self.base(t)
        end
        data = data+"\n"

        offset = 0
        if t >= 0
            offset = self.finish(t)
        end
        n1, n2 = self.node(p1), self.node(p2)
        sha1 = Digest::SHA1.new
        # p "addrevision ->"
        # p n1
        # p n2
        # p text
        node = sha1.update(n1 + n2 + text).hexdigest
        e = [offset, data.length, base, p1, p2, node]

        @index << e
        entry = e.join(' ') +"\n"
        # p "Look here"
        # p e
        # p data
        # entry = struct.pack(">5l20s", *e)
        @nodemap[node] = n
        # data << "\n" if data[-1] != "\n"
        self.open(@indexfile, "a").write(entry)
        self.open(@datafile, "a").write(data)
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
