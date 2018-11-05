require 'changelog'

class Repository
    
    # List of head revisions (chnageLogs??)
    @heads = []
    # constructor
    # path-> path to Repo root
    def initialize(path)
        # create .jsaw folder with all relevant files 

        # initilize head changeLog
        @rootChangeLog = ChangeLog.new(self, path)
        # initialize manifestLog

        # fileLogs???
    end

    # commit method
    def commit(message)
        # TODO

    end

    # method to return head Revision of Repo
    def getHeadRevision()
        # find and return head Revision

    end

    # other methods .... 

end
