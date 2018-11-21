require "minitest/autorun"
require_relative "../../src/diff"

class TestMeme < Minitest::Test
  def setup
  end

  def test_linesplit
      str = "hello\nworld"
      assert_equal ["hello\n", "world"], DiffUtils.linesplit(str)
  end
end
