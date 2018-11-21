require "minitest/autorun"
require_relative "../../src/filelog"
require_relative "../../src/repository"

class FilelogTest < Minitest::Test

    def test_init
        repo = Repository.new()
        fl = Filelog.new(repo, "path")

        # ensure file will go into data or index folder
        assert_equal false, (fl.datafile =~ /data\/*{40}/).nil?
        assert_equal false, (fl.indexfile =~ /index\/*{40}/).nil?
    end

end
