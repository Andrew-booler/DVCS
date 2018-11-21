require "minitest/autorun"

class JSAWTest < Minitest::Test
  def setup
      %x(echo rm -rf .jsaw)
  end

  def test_commit
  end
end
