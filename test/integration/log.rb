require "minitest/autorun"

class LogTest < Minitest::Test

    def setup
        Dir.chdir "src" if File.basename(Dir.getwd) != "src"
        `rm -rf .jsaw`
        `rm test.txt`
        `./jsaw init`
    end

    def test_log
        `touch test.txt`
        `echo "hello world" >> test.txt`
        `./jsaw add test.txt`
        `./jsaw commit "added test.txt"`
        out = `./jsaw log`
        assert_equal 7, out.lines.length
    end
end
