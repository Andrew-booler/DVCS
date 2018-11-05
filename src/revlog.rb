require 'digest'

@@nullid = Digest::SHA1.hexdigest ''

class Revid
  def initialize(id_string)
    attr_reader :offset, :size, :base, :p1, :p2, :nodeid
    para_list=id_string.split(';')
    if para_list.length==6 then
      @offset=para_list[0]
      @size=para_list[1]
      @base=para_list[2]
      @p1=para_list[3]
      @p2=para_list[4]
      @nodeid=para_list[5]
    end
  end

  def tostring()
    [@offset,@size,@base,@p1,@p2,@nodeid].inject(){|res,item| res+";"+item }
  end
end

class Revnode
  def initialize()
end


class Revlog
  def initialize(indexfile, datafile)
    @indexfile = indexfile
    @datafile = datafile
    @index = []
    @nodemap = {-1 => @@nullid, @@nullid => -1}
    n = 0
    self.open(@indexfile) do |file|
      file.each_line do |line|
        node = Revid.new(line)
        @nodemap[node.nodeid] = n
        @index<< node
        n+=1
      end
    end
  end

  def open(filename, mode="r") File.new(filename,mode=mode) end

  def len() @index.length-1 end

  def node(idx)
end