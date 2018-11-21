require "minitest/autorun"

class AddTest < Minitest::Test

    def setup
        Dir.chdir "src" if File.basename(Dir.getwd) != "src"
        `rm -rf .jsaw`
        `rm test.txt`
        `./jsaw init`
    end

    def test_add
        `touch test.txt`
        `echo "hello world" >> test.txt`
        `./jsaw add test.txt`
        lines = File.open(".jsaw/to-add").read().lines

        assert lines.length == 1
        assert_equal "test.txt\n", lines[0]

        `./jsaw add diff.rb`
        lines = File.open(".jsaw/to-add").read().lines

        assert lines.length == 2
        assert_equal "test.txt\n", lines[0]
        assert_equal "diff.rb\n", lines[1]
    end
end
