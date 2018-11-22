require "minitest/autorun"
require_relative "../../src/revlog"

class RevlogTest < Minitest::Test

    def setup
    end

    def test_init
        r = Revlog.new("ifile", "dfile")
        assert_equal "ifile", r.indexfile
        assert_equal "dfile", r.datafile
    end

    def test_addrevision

        r = Revlog.new("ifile", "dfile")
        r.addrevision("text")

        assert File.exist? "dfile"
        assert File.exist? "ifile"

        d = File.open("dfile").read
        # assert_equal "text", d

        i = File.open("ifile").read
        # [offset, data.length, base, p1, p2, node]
        # 0 7 0 -1 -1 5ded4bcd3604b28e29f117aec315037a7cb4311c
        info = i.split(" ")
        offset = info[0]
        data_length = info[1]
        base = info[2]
        p1 = info[3]
        p2 = info[4]
        node = info[5]

        `rm -rf .jsaw`
        `rm dfile`
        `rm ifile`
    end

end
