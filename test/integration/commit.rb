require "minitest/autorun"

class JSAWTest < Minitest::Test
    def cleanup
        Dir.chdir "src" if File.basename(Dir.getwd) != "src"
        `rm -rf .jsaw`
        `rm test.txt`
    end

    def setup
        cleanup
        `./jsaw init`
    end

    def test_commit
        `touch test.txt`
        `echo "hello world" >> test.txt`
        `./jsaw add test.txt`
        `./jsaw commit "added test.txt"`
    end
end
