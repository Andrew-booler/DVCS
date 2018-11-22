require "minitest/autorun"
require_relative "../../src/repository"

class RepositoryTest < Minitest::Test

    def setup
        `rm -rf .jsaw`
    end

    def test_init
        repo = Repository.new(nil, true)
        Dir.chdir "src" if File.basename(Dir.getwd) == "DVCS"
        Dir.chdir ".jsaw" if File.basename(Dir.getwd) == "src"

        assert File.exist? "data"
        assert File.exist? "index"
        assert File.exist? "dircache"
        assert File.exist? "to-add"
        assert File.exist? "to-delete"
    end

    # def test_delete
    #     repo = Repository.new(nil, true)
    #     repo.delete(["test.txt"])
    #     Dir.chdir "src" if File.basename(Dir.getwd) == "DVCS"
    #     t = File.open(".jsaw/to-delete").read
    #     assert_equal "test.txt", t
    # end

end
