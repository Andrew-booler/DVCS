require 'digest'
require 'fileutils'

@@nullid = Digest::SHA1.hexdigest ''

class Revid
  def initialize(id_string = '', nodeid = '', p1 = '', p2 = '',offset=0)
    attr_reader  :offset, :p1, :p2, :nodeid
    para_list=id_string.split(';')
    if para_list.length==3 then
      #@size=para_list[1]
      @p1=para_list[0]
      @p2=para_list[1]
      @nodeid=para_list[2]
      @offset=para_list[3]
    else
      @nodeid = nodeid
      @p1 = p1
      @p2 = p2
      @offset = offset
    end
  end

  def tostring()
    [@p1,@p2,@nodeid,@offset].inject(){|res,item| res+";"+item }#@size
  end
end

class Revnode
  def initialize(content='',recover=false)
    if recover
      @content = content
    else
      @content = content.dump
    end
  end

  def tostring()
    @content
  end

  def get_content()
    @content.undump
  end

  def hashcode()
    Digest::SHA1.hexdigest @content
  end
end


class Revlog
  def initialize(indexfile, datafile)
    @indexfile = indexfile
    @datafile = datafile

    if not File.exist? @indexfile
      FileUtils.mkdir_p File.dirname @indexfile
      File.new(@indexfile,"w")
    end

    if not File.exist? @datafile
      FileUtils.mkdir_p File.dirname @datafile
      File.new(@datafile,"w")
    end

    @index = []
    @nodemap = {-1 => @@nullid, @@nullid => -1}
    @dataset = []
    n = 0
    self.open(@indexfile).each_line do |line|
      line = line.strip
      node = Revid.new(line)
      @nodemap[node.nodeid] = n
      @index<< node
      n+=1
    end

    self.open(@datafile).each_line do |line|
      line = line.strip
      @dataset << Revnode.new(line,true)
    end
  end

  def open(filename, mode="r") File.open(filename,mode=mode) end

  def top() @index.length-1 end

  def datatop() @dataset.length-1 end

  def node(idx)
    if idx<0
      @@nullid
    else
      @index[idx].nodeid
    end
  end

  def rev_seq(node)
    @nodemap[node]
  end

  def parents(idx) [@index[idx].p1,@index[idx].p2] end
  def file_index(idx) @index[idx].offset end


  def revision(rev) @dataset[rev.offset] end

  def add_revision(revnode,p1,p2)
    if revnode.kind_of?(Revnode)
      if p1 == nil
        p1 = self.top()
      end
      if p2 == nil
        p2 = -1
      end
      @dataset<<revnode
      idxnode = Revid.new('',revnode.hashcode,p1,p2,self.datatop)
      @index<<idxnode
      @roadmap[idxnode.nodeid]=self.top

      self.saveid()
      self.savedata()
    end

  end

  def saveid()
    self.open(@indexfile,'w') do |file|
      @index.each do |idnode|
        file.write(idnode.tostring+'\n')
      end
    end
  end

  def savedata()
    self.open(@datafile,'w') do |file|
      @dataset.each do |datanode|
        file.write(datanode.tostring+'\n')
      end
    end
  end
end