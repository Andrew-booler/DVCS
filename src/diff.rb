require 'diff/lcs'

# Example usage
#
# p textdiff("aa\nbb\n", "bb\naa\n") # produces [[["-", 0, "aa\n"]], [["+", 1, "aa\n"]]]
# p patch("aa\nbb\n", textdiff("aa\nbb\n", "bb\naa\n")) # produces ["bb\n", "aa\n"]
#
# use this in other files like this:
# require_relative 'diff.rb'
# DiffUtils.linesplit("sss")

module DiffUtils

    def linesplit(str)
        str.lines
    end

    def textdiff(prev_str, new_str)
        return Diff::LCS.diff(linesplit(prev_str), linesplit(new_str))
    end

    def patch(prev_str, diffs)
        return prev_str if diffs == ""
        return Diff::LCS.patch!(linesplit(prev_str), diffs)
    end

    module_function :linesplit
    module_function :textdiff
    module_function :patch

end
