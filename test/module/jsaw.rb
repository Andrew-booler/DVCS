require "minitest/autorun"

class JSAWTest < Minitest::Test

    def setup
        Dir.chdir "src" if File.basename(Dir.getwd) != "src"
    end

    def test_invalid_command
        out = `./jsaw dog`
        assert_equal "jsaw: 'dog' is not a valid command. See 'jsaw help'.\n", out
    end

    def test_commit_requires_msg
        out = `./jsaw commit`
        assert_equal "You must have a message to commit\n", out
    end
end
