require 'digest'
require 'fileutils'

NULLID = Digest::SHA1.hexdigest ''

#class of idnode in revlog
class Revid
    attr_reader  :offset, :p1, :p2, :nodeid
  def initialize(id_string = '',  p1 = '', p2 = '',nodeid = NULLID,offset=-1)

    para_list=id_string.split(';')
    if para_list.length==5   then
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
    [@p1,@p2,@nodeid,@offset,@hashcode].inject(){|res,item| res.to_s+";"+item.to_s }#@size
  end

  #return the parents
  def parents()
    [@p1,@p2]
  end

end

#node that save the content, please extend it
class Revnode
  def initialize(content='',recover=false)
    if recover
      @content = content.undump
    else
      @content = content
    end
  end

  def tostring()
    @content.dump
  end


#please overwrite it and call the super function with a string
  def get_content()
    @content
  end

  def hashcode()
    Digest::SHA1.hexdigest @content
  end
end


class Revlog
  #indexfile: file to store the index nodes
  # datafile: file to store the data
  # create the indexfile and the datafile if they do not exist return an empty Revlog
  # or restore the Revlog from the files
  attr_reader :index
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

    @nodemap = { NULLID => Revid.new()}

    @dataset = []
    self.open(@indexfile).each_line do |line|
      line = line.strip
      node = Revid.new(line)
      @nodemap[node.nodeid] = node
      @index<< node.nodeid

    end
    # p @index
    # p @index

    self.open(@datafile).each_line do |line|
      line = line.strip
      @dataset << Revnode.new(line,true)
    end
    self
  end

  def open(filename, mode="r") 
    # p filename 
    File.open(filename,mode=mode) 
  end

  #index of the last element in index node list
  def top() @index[-1]  end

  #index of the last element in revnode list
  def datatop() @dataset.length-1 end

  #using the offset of the idnode to get the node
  def node(idx)
    if not @nodemap.keys.include?(idx)
      @nodemap[NULLID]
    else
      @nodemap[idx]
    end
  end

  #using the hashcode of the idnode to get the node
  # def rev_seq(id)
  #   @nodemap[id]
  # end

  #using the idnode to find the revnode
  def revision(idnode) 
    if idnode.offset > -1
      @dataset[idnode.offset]
    else
      Revnode.new()
    end
  end


  #add a revision,
  # revnode: a revnode
  # p1 hashcode of parent1
  # p2 hashcode of parent2
  def add_revision(revnode,p1=nil,p2=nil)
    if revnode.kind_of?(Revnode)
      if p1 == nil
        p1 = self.node(self.top).nodeid
      end
      if p2 == nil
        p2 = NULLID
      end
      @dataset<<revnode
      idxnode = Revid.new('',p1,p2,revnode.hashcode,self.datatop)
      @index<<idxnode.nodeid
      
      @nodemap[idxnode.nodeid]=idxnode
      self.saveid()
      self.savedata()
    end
  end

  def saveid()
    # p self.open(@indexfile,'w')
    # p @nodemap
    file = self.open(@indexfile,'w')
    # p @index
    @index.each do |id|
      if id != NULLID
        # p @nodemap[id]
        file.write(@nodemap[id].tostring)
        file.write "\n" 
      end

    end
    # self.open(@indexfile,'w') do |file|
    #   @index.each do |idnode|
    #     file.write(idnode.tostring+'\n')
    #   end
    # end
  end

  def savedata()
    self.open(@datafile,'w') do |file|
      @dataset.each do |datanode|
        file.write(datanode.tostring+"\n")
      end
    end
  end
end