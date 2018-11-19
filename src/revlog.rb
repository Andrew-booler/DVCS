require 'digest'
require 'fileutils'

NULLID = Digest::SHA1.hexdigest ''

#class of idnode in revlog
class Revid
    attr_reader  :offset, :p1, :p2, :nodeid, :hashcode
    def initialize(id_string = '',  p1 = '', p2 = '',nodeid = -1,offset=-1,hashcode=NULLID)

        para_list=id_string.split(';')
        if para_list.length==5   then
            #@size=para_list[1]
            @p1=para_list[0]
            @p2=para_list[1]
            @nodeid=para_list[2]
            @offset=para_list[3]
            @hashcode=para_list[4]
        else
            @nodeid = nodeid
            @p1 = p1
            @p2 = p2
            @offset = offset
            @hashcode = hashcode
        end
    end

    def tostring()
        [@p1,@p2,@nodeid,@offset,@hashcode].inject(){|res,item| res+";"+item }#@size
    end

    #return the parents
    def parents()
        [@p1,@p2]
    end

    #return the hashcode of the node
    def hashcode()
        @hashcode
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
    def initialize(indexfile, datafile)
        @indexfile = indexfile
        @datafile = datafile

        if not File.exist? self.join(@indexfile)
            # FileUtils.mkdir_p File.dirname @indexfile
            File.new(self.join(@indexfile),"w")
        end

        if not File.exist? self.join(@datafile)
            # FileUtils.mkdir_p File.dirname @datafile
            File.new(self.join(@datafile),"w")
        end

        @index = []
        @nodemap = {-1 => NULLID, NULLID => -1}
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
        self
    end

    def open(filename, mode="r")
        File.open(".jsaw/"+filename,mode=mode)
    end

    def join(f)
        path = Dir.getwd()
        File.join(path, ".jsaw", f)
    end

    #index of the last element in index node list
    def top()
        @index.length-1
    end

    #index of the last element in revnode list
    def datatop()
        @dataset.length-1
    end

    #using the offset of the idnode to get the node
    def node(idx)
        idx < 0 ? nil : @index[idx]
    end

    #using the hashcode of the idnode to get the node
    def rev_seq(hashcode)
        @nodemap[hashcode]
    end

    #using the idnode to find the revnode
    def revision(idnode) @dataset[idnode.offset] end

        #add a revision,
        # revnode: a revnode
        # p1 hashcode of parent1
        # p2 hashcode of parent2
        def add_revision(revnode,p1=nil,p2=nil)
            if revnode.kind_of?(Revnode)
                p1 = self.node(self.top).hashcode if p1.nil?
                p2 = -1 if p2.nil?
                @dataset << revnode
                idxnode = Revid.new('', p1, p2, self.top+1, self.datatop, revnode.hashcode)
                @index << idxnode
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
