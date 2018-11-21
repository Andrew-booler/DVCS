require "minitest/autorun"
require_relative "../../src/diff"

class DiffTest < Minitest::Test

    # sanity check test
    def test_linesplit
        str = "hello\nworld"
        assert_equal ["hello\n", "world"], DiffUtils.linesplit(str)
        assert_equal str.lines, DiffUtils.linesplit(str)
    end

    # spec test
    def test_textdiff_and_patch
        p1 = "hello world!"
        p2 = "world hello!"
        diff = DiffUtils.textdiff(p1, p2)
        my_diff = [[["-", 0, "hello world!"], ["+", 0, "world hello!"]]]

        patch = DiffUtils.patch(p1, diff)
        my_patch = DiffUtils.patch(p1, diff)
        assert_equal patch, [p2]
        assert_equal my_patch, [p2]

        f1 = "hello\n   world\n     !"
        f2 = "hello friend"
        diff = DiffUtils.textdiff(f1, f2)
        my_diff = [[["-", 0, "hello\n"], ["-", 1, "   world\n"], ["+", 0, "hello friend"], ["-", 2, "     !"]]]

        patch = DiffUtils.patch(f1, diff)
        my_patch = DiffUtils.patch(f1, diff)
        assert_equal patch, [f2]
        assert_equal my_patch, [f2]
    end

end
