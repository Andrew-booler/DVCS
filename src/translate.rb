def merge(other)
    o_n = self.mergedag(other)
    return self.resolvedog(o_n[0], o_n[1])
end

def revisions(list)
    list.each{|r| yield(self.revision(r)) }
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
    text = data[:last]
    for r in (base+1 ... rev+1)
        s = self.length(r)
        b = data[last:last+s]
        text = patch(text, b)
        last = last + s
    end
    parents = self.parents(rev)
    p1 = parents[0]
    p2 = parents[1]
    n1 = self.node(p1)
    n2 = self.node(p2)
    sha1 = Digest::SHA1.new
    node = sha1.update(n1+n2+text).hexdigest()
    if self.node(rev) != node
        raise "Consistency check failed on #{self.datafile} : #{rev}"
    end
    return text
end