require "minitest/autorun"

class InitTest < Minitest::Test
    def setup
        Dir.chdir "src" if File.basename(Dir.getwd) != "src"
        `rm -rf .jsaw`
    end

    def test_init
        `./jsaw init`
        assert File.directory? ".jsaw"
    end
end
