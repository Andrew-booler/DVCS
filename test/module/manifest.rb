require "minitest/autorun"
require_relative "../../src/manifest"
require_relative "../../src/repository"

class ManifestTest < Minitest::Test

    def test_init
        repo = Repository.new()
        m = Manifest.new(repo)
        # TODO: fix this
        # Dir.chdir "src" if File.basename(Dir.getwd) != "src"
        # `./jsaw init`
        # p File.exist? ".jsaw"
        # Dir.chdir ".jsaw" if File.basename(Dir.getwd) != ".jsaw"
        # assert File.exist? "00manifest.i"
        # assert File.exist? "00manifest.d"
    end

    def filemap_to_s(filemap)
        files = filemap.keys
        files.sort!
        arr = []
        files.each {|name| arr << filemap[name].to_s + ' ' + name.to_s}
        text = arr.join("\n")
    end

    def test_filemap_to_s
        fmap = { "f1.txt" => "f36b612c565067798591b4a7c310b746f58510c0", "f2.txt" => "049374a8e00e957f4a4650e58151374486fb8c6b" }
        fmap_s = filemap_to_s(fmap)
        p fmap_s
        assert_equal "f36b612c565067798591b4a7c310b746f58510c0 f1.txt\n049374a8e00e957f4a4650e58151374486fb8c6b f2.txt", fmap_s
    end

end
