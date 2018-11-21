require "minitest/autorun"
require_relative "../../src/changelog"

class ChangelogTest < Minitest::Test
    def setup
    end

    def extract(text)
        l = text.lines
        manifest = l[0][0..-2]
        user = l[1][0..-2]
        date = l[2][0..-2]
        last = l.index("\n")
        files = l[3..last].collect {|f| f[0..-2]}
        desc = l[last+1..-1].join " "
        [manifest, user, date, files, desc]
    end

    def test_extract
        # mercurial reference
        # ('\xf3ka,VPgy\x85\x91\xb4\xa7\xc3\x10\xb7F\xf5\x85\x10\xc0', 'Simon@MacBook-Pro.local', '1542840375 28800', ['mdiff.py'], 'commit\n')
        t = "f36b612c565067798591b4a7c310b746f58510c0\nSimon@MacBook-Pro.local\n1542840375 28800\nmdiff.py\n\ncommit\n"
        out = extract(t)
        assert_equal "f36b612c565067798591b4a7c310b746f58510c0", out[0]
        assert_equal "Simon@MacBook-Pro.local", out[1]
        assert_equal "1542840375 28800", out[2]
        assert_equal ["mdiff.py"], out[3] #TODO need to fix exract to pass this
        assert_equal "commit\n", out[4]
    end
end
