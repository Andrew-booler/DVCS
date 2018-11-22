require "minitest/autorun"

class CommitTest < Minitest::Test

    def setup
        Dir.chdir "src" if File.basename(Dir.getwd) != "src"
        `rm -rf .jsaw`
        `rm test.txt`
        `./jsaw init`
    end

    def test_commit
        `touch test.txt`
        `echo "hello world" >> test.txt`
        `./jsaw add test.txt`
        `./jsaw commit "added test.txt"`
    end
end